IF OBJECT_ID('[dbo].[SpNavigationActionIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpNavigationActionIns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : Pratigya
-- Create date : 02/13/2019
-- Description : Inserts into table Navigation
-- ===================================================================

-- ===================================================================
-- Author      : melina.sharma
-- Create date : 03/16/2019
-- Description : Inserts into table Navigation
-- ===================================================================

CREATE PROCEDURE [dbo].[SpNavigationActionIns] ( @Json nVARCHAR (MAX) OUTPUT )
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
                    DECLARE @na TABLE
                    (   NavigationActionId INT,
                        NavigationId INT NOT NULL,
                        Action NVARCHAR (50) NOT NULL,
                        Description VARCHAR (200),
                        NavigationActionTypeListItemId INT,
                        ResourceId INT NOT NULL,
                        ApplicationId INT,
						Icon VARCHAR(25),
                        RoleId INT );
                    INSERT INTO @na ( NavigationActionId,
                                      NavigationId,
                                      Action,
                                      Description,
                                      NavigationActionTypeListItemId,
                                      ResourceId,
                                      ApplicationId,
									  	Icon,
                                      RoleId )
                    SELECT oj.navigationActionId,
                           n.NavigationId,
                           oj.action,
                           oj.description,
                           li.ListItemId,
                           r.ResourceId,
                           a.ApplicationId,
						   oj.icon,
                           r2.RoleId
                    FROM
                           OPENJSON (@Json)
                               WITH ( navigationActionId INT,
                                      navigationId INT,
                                      action NVARCHAR (50),
                                      description VARCHAR (200),
                                      navigationActionTypeListItemId INT,
                                      navigationActionType VARCHAR (50),
                                      resourceId INT,
                                      resource NVARCHAR (100),
                                      applicationId INT,
                                      roleId INT,
                                      application VARCHAR (50),
                                      role VARCHAR (25),
                                      navigation NVARCHAR (100),
									  icon VARCHAR(25),
                                      uRL VARCHAR (50)) AS oj
                           INNER JOIN dbo.ListItem AS li ON li.ListItemId = oj.navigationActionTypeListItemId
                                                            OR li.ListItem = oj.navigationActionType
                           INNER JOIN dbo.ListItemCategory AS lic ON lic.ListItemCategoryId = li.ListItemCategoryId
                                                                     AND lic.Category = 'NavigationActionType'
                           INNER JOIN dbo.Navigation AS n ON ( n.Navigation = oj.navigation
                                                               AND n.URL = oj.uRL )
                                                             OR n.NavigationId = oj.navigationId
                           INNER JOIN dbo.Resource AS r ON r.ResourceId = oj.resourceId
                                                           OR r.Resource = oj.resource
                           LEFT JOIN dbo.Application AS a ON a.ApplicationId = oj.applicationId
                                                             OR a.Application = oj.application
                           LEFT JOIN dbo.Role AS r2 ON r2.Role = oj.role
                                                       OR r2.RoleId = oj.roleId;


                    INSERT INTO dbo.NavigationAction ( NavigationId,
                                                       Action,
                                                       Description,
                                                       NavigationActionTypeListItemId,
                                                       ResourceId,
													   Icon, 
                                                       UserPersonId )
                    SELECT DISTINCT n.NavigationId,
                           n.Action,
                           n.Description,
                           n.NavigationActionTypeListItemId,
                           n.ResourceId,
						   n.Icon,
                           @UserPersonId
                    FROM   @na AS n
                           LEFT JOIN dbo.NavigationAction AS na ON na.Action = n.Action
                                                                   AND na.NavigationId = n.NavigationId
                    WHERE  na.NavigationActionId IS NULL;

                    SELECT @Json = ( SELECT na.NavigationActionId AS navigationActionId,
                                            n.Action AS action,
                                            n.ApplicationId AS applicationId,
                                            n.RoleId AS roleId
                                     FROM   @na AS n
                                            INNER JOIN dbo.NavigationAction AS na ON na.Action = n.Action
                                                                                     AND na.NavigationId = n.NavigationId
                                   FOR JSON PATH, INCLUDE_NULL_VALUES );

                END;

        END TRY
        BEGIN CATCH
            THROW;
        END CATCH;
    END;










GO
