IF OBJECT_ID('[dbo].[SpApplicationRoleNavigationIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpApplicationRoleNavigationIns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : Pratigya.Thapa
-- Create date : 02/13/2019
-- Description : Inserts into table ApplicationRoleNavigation
-- ===================================================================
--modified by: Mrijan on 5/14/2021
-- display order to be pulled from navigation table in case of not provided from sproletsk
-----------------------------
CREATE PROCEDURE [dbo].[SpApplicationRoleNavigationIns]
(
    @Json VARCHAR (MAX))
AS
    BEGIN
        SET NOCOUNT ON;

        BEGIN TRY

            DECLARE @UserPersonId INT = dbo.SfPersonIdGet ();
            IF ( @UserPersonId = 0 )
                BEGIN
                    RAISERROR ('Insert person not found.', 16, 1);
                END;
            ELSE
                BEGIN

                    DECLARE @arn TABLE
                    (   ApplicationRoleId INT NOT NULL ,
                        DisplayOrder INT ,
                        NavigationId INT NOT NULL );
                    INSERT INTO @arn ( ApplicationRoleId ,
                                       DisplayOrder ,
                                       NavigationId )
                                SELECT ar.ApplicationRoleId ,
                                       ISNULL (oj2.displayOrder, n.DisplayOrder) ,
                                       n.NavigationId
                                FROM
                                       OPENJSON (@Json)
                                           WITH ( applicationRoleId INT ,
                                                  navigationIdList NVARCHAR (MAX) AS JSON ) AS oj
                                       CROSS APPLY ( SELECT navigationId ,
                                                            displayOrder
                                                     FROM
                                                            OPENJSON (oj.navigationIdList)
                                                                WITH ( navigationId INT ,
                                                                       displayOrder INT )) AS oj2
                                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = oj2.navigationId
                                       INNER JOIN dbo.ApplicationRole AS ar ON ar.ApplicationRoleId = oj.applicationRoleId;



                    INSERT INTO dbo.ApplicationRoleNavigation ( ApplicationRoleId ,
                                                                NavigationId ,
                                                                DisplayOrder ,
                                                                UserPersonId )
                                SELECT a.ApplicationRoleId ,
                                       a.NavigationId ,
                                       a.DisplayOrder ,
                                       @UserPersonId
                                FROM   @arn AS a
                                       LEFT JOIN dbo.ApplicationRoleNavigation AS arn ON  arn.ApplicationRoleId = a.ApplicationRoleId
                                                                                      AND arn.NavigationId = a.NavigationId
                                WHERE  arn.ApplicationRoleNavigationId IS NULL;

                    SELECT @Json = ( SELECT a.ApplicationRoleId ,
                                            a.NavigationId
                                     FROM   @arn AS a
                                            INNER JOIN dbo.ApplicationRoleNavigation AS arn ON  arn.ApplicationRoleId = a.ApplicationRoleId
                                                                                            AND arn.NavigationId = a.NavigationId
                                   FOR JSON AUTO, INCLUDE_NULL_VALUES );

                END;
        END TRY
        BEGIN CATCH
            THROW;
        END CATCH;
    END;




GO
