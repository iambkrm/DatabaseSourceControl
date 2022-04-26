IF OBJECT_ID('[dbo].[SpNavigationActionNewTsk]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpNavigationActionNewTsk];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : melina.sharma
-- Create date : 03/16/2019
-- Description : Inserts into table NavigationAction and ApplicationRoleNavigationAction
-- ===================================================================
/*
'[{"navigationId":17,"action":"AutoMatch ","description": "Auto Match ",
 "navigationActionType":"Single", "resource": "Unmapped", "application":"PMS", "role": "SuperAdmin", "icon" : "" }]
*/

CREATE PROCEDURE [dbo].[SpNavigationActionNewTsk]
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

                    EXEC dbo.SpNavigationActionIns @Json = @Json OUTPUT;

                    EXEC dbo.SpApplicationRoleNavigationActionIns @Json = @Json;

                    EXEC dbo.[SpApplicationNavigationActionIns] @Json = @Json;


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
