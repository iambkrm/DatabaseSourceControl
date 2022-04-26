IF OBJECT_ID('[dbo].[SpNavigationNodeIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpNavigationNodeIns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : nho
-- Create date : 11/18/2019
-- Description : Inserts into table NavigationNode
-- ===================================================================

CREATE PROCEDURE [dbo].[SpNavigationNodeIns]
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
                    INSERT INTO dbo.NavigationNode ( NavigationId ,
                                                     NodeId ,
                                                     UserPersonId )
                                SELECT oj.navigationId ,
                                       o.NodeId ,
                                       @UserPersonId
                                FROM
                                       OPENJSON (@Json)
                                           WITH ( navigationId INT ,
                                                  officeId INT ) AS oj
                                       INNER JOIN dbo.Office AS o ON o.OfficeId = oj.officeId
                                       LEFT JOIN dbo.NavigationNode AS nn ON  nn.NavigationId = oj.navigationId
                                                                          AND nn.NodeId = o.NodeId
                                WHERE  nn.NavigationNodeId IS NULL
                                AND    ISNULL (oj.officeId, 0) <> 0;

                    INSERT INTO dbo.NavigationNode ( NavigationId ,
                                                     NodeId ,
                                                     UserPersonId )
                                SELECT oj.navigationId ,
                                       o.NodeId ,
                                       @UserPersonId
                                FROM
                                       OPENJSON (@Json)
                                           WITH ( navigationId INT ,
                                                  officeId INT ) AS oj
                                       CROSS JOIN dbo.Office AS o
                                       LEFT JOIN dbo.NavigationNode AS nn ON  nn.NavigationId = oj.navigationId
                                                                          AND nn.NodeId = o.NodeId
                                WHERE  nn.NavigationNodeId IS NULL
                                AND    ISNULL (oj.officeId, 0) = 0;
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
