IF OBJECT_ID('[dbo].[SpNavigationNewTsk]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpNavigationNewTsk];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : mrijan
-- Create date : 11
-- Description : Inserts into table NavigationAction and ApplicationRoleNavigationAction
-- ===================================================================


CREATE PROCEDURE [dbo].[SpNavigationNewTsk]
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

                    EXEC dbo.SpNavigationIns @Json = @Json OUTPUT;
					
                    EXEC dbo.SpNavigationNodeIns @Json = @Json

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
