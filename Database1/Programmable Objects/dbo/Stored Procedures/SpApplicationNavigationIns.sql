IF OBJECT_ID('[dbo].[SpApplicationNavigationIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpApplicationNavigationIns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : melina.sharma
-- Create date : 06/01/2020
-- Description : Inserts into table ApplicationNavigation
-- ===================================================================

CREATE PROCEDURE [dbo].[SpApplicationNavigationIns]
(
    @Json NVARCHAR (MAX))
AS
    BEGIN
        SET NOCOUNT ON;

        BEGIN TRY
            BEGIN TRANSACTION;

            DECLARE @UserPersonId INT = dbo.SfPersonIdGet ();
            IF ( @UserPersonId = 0 )
                BEGIN
                    RAISERROR ('Insert person not found.', 16, 1);
                END;

            ELSE
                BEGIN

                    DECLARE @arn TABLE
                    (   ApplicationId INT NOT NULL ,
                        NavigationId INT NOT NULL ,
                        ParentApplicationId INT );
                    INSERT INTO @arn ( ApplicationId ,
                                       NavigationId ,
                                       ParentApplicationId )
                                SELECT DISTINCT ar.ApplicationId ,
                                                n.NavigationId ,
                                                oj.parentApplicationId
                                FROM
                                       OPENJSON (@Json)
                                           WITH ( applicationRoleId INT ,
                                                  navigationIdList NVARCHAR (MAX) AS JSON ,
                                                  parentApplicationId INT ) AS oj
                                       CROSS APPLY ( SELECT navigationId
                                                     FROM
                                                            OPENJSON (oj.navigationIdList)
                                                                WITH ( navigationId INT )) AS oj2
                                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = oj2.navigationId
                                       INNER JOIN dbo.ApplicationRole AS ar ON ar.ApplicationRoleId = oj.applicationRoleId;

                    INSERT INTO dbo.ApplicationNavigation ( ApplicationId ,
                                                            NavigationId ,
                                                            ParentApplicationId ,
                                                            UserPersonId )
                                SELECT a.ApplicationId ,
                                       a.NavigationId ,
                                       a.ParentApplicationId ,
                                       @UserPersonId
                                FROM   @arn AS a
                                       LEFT JOIN dbo.ApplicationNavigation AS an ON  an.ApplicationId = a.ApplicationId
                                                                                 AND an.NavigationId = a.NavigationId
                                WHERE  an.ApplicationNavigationId IS NULL;
                END;
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;

    END;
GO
