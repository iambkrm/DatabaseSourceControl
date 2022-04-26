IF OBJECT_ID('[dbo].[SpApplicationRoleNavigationActionIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpApplicationRoleNavigationActionIns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : Pratigya.Thapa
-- Create date : 02/13/2019
-- Description : Inserts into table ApplicationRoleNavigationAction
-- ===================================================================

-- ===================================================================
-- Author      : melina.sharma
-- Create date : 03/16/2019
-- Description : Inserts into table ApplicationRoleNavigationAction
-- ===================================================================

CREATE PROCEDURE [dbo].[SpApplicationRoleNavigationActionIns]
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

                    CREATE  TABLE #a
                    (   ApplicationRoleId INT NOT NULL ,
                        NavigationActionId INT NOT NULL );
                    INSERT INTO #a ( ApplicationRoleId ,
                                     NavigationActionId )
                                SELECT DISTINCT ar.ApplicationRoleId ,
                                       oj.navigationActionId
                                FROM
                                       OPENJSON (@Json)
                                           WITH ( roleId INT ,
                                                  applicationId INT ,
                                                  navigationActionId INT ,
                                                  applicationRoleId INT ) AS oj
                                       INNER JOIN dbo.ApplicationRole AS ar ON ( ar.ApplicationId = oj.applicationId
                                                                             AND ar.RoleId = oj.roleId )
                                                                            OR ar.ApplicationRoleId = oj.applicationRoleId;


                    INSERT INTO dbo.ApplicationRoleNavigationAction ( ApplicationRoleId ,
                                                                      NavigationActionId ,
                                                                      UserPersonId )
                                SELECT a.ApplicationRoleId ,
                                       a.NavigationActionId ,
                                       @UserPersonId
                                FROM   #a AS a
                                       LEFT JOIN dbo.ApplicationRoleNavigationAction AS arna ON  arna.ApplicationRoleId = a.ApplicationRoleId
                                                                                             AND arna.NavigationActionId = a.NavigationActionId
                                WHERE  arna.ApplicationRoleNavigationActionId IS NULL;
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
