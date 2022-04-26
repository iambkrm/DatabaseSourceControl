IF OBJECT_ID('[dbo].[SpNavigationIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpNavigationIns];

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

CREATE PROCEDURE [dbo].[SpNavigationIns]
(
    @Json VARCHAR (MAX) OUTPUT )
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

                    CREATE TABLE #n
                    (   Id INT IDENTITY (1, 1) ,
                        Navigation NVARCHAR (100) NOT NULL ,
                        URL VARCHAR (50) NOT NULL ,
                        IsExternal BIT NOT NULL ,
                        ParentNavigationName NVARCHAR (100) ,
                        ParentUrl NVARCHAR (100) ,
                        NavigationTypeListItemId INT NOT NULL ,
                        RootNavigationName NVARCHAR (100) ,
                        Icon VARCHAR (25) NOT NULL ,
                        DisplayOrder INT NOT NULL ,
                        ResourceId INT NOT NULL );
                    INSERT INTO #n ( Navigation ,
                                     URL ,
                                     IsExternal ,
                                     ParentNavigationName ,
                                     ParentUrl ,
                                     NavigationTypeListItemId ,
                                     RootNavigationName ,
                                     Icon ,
                                     DisplayOrder ,
                                     ResourceId )
                                SELECT oj.navigation ,
                                       oj.uRL ,
                                       oj.isExternal ,
                                       oj.parentNavigationName ,
                                       oj.parentURL ,
                                       ISNULL (oj.navigationTypeListItemId, li.ListItemId) ,
                                       oj.rootNavigationName ,
                                       oj.icon ,
                                       oj.displayOrder ,
                                       oj.resourceId
                                FROM
                                       OPENJSON (@Json)
                                           WITH ( navigation NVARCHAR (100) ,
                                                  uRL VARCHAR (50) ,
                                                  isExternal BIT ,
                                                  parentNavigationName NVARCHAR (100) ,
                                                  parentURL VARCHAR (50) ,
                                                  navigationType VARCHAR (50) ,
                                                  navigationTypeListItemId INT ,
                                                  rootNavigationName NVARCHAR (100) ,
                                                  icon VARCHAR (25) ,
                                                  displayOrder INT ,
                                                  resourceId INT ) AS oj
                                       LEFT JOIN dbo.ListItem AS li
                                                 INNER JOIN dbo.ListItemCategory AS lic ON lic.ListItemCategoryId = li.ListItemCategoryId
                                                                                           AND lic.Category = 'NavigationType' ON li.ListItem = oj.navigationType;




                    INSERT INTO dbo.Navigation ( Navigation ,
                                                 URL ,
                                                 IsExternal ,
                                                 NavigationTypeListItemId ,
                                                 Icon ,
                                                 DisplayOrder ,
                                                 ResourceId ,
                                                 UserPersonId )
                                SELECT n.Navigation ,
                                       n.URL ,
                                       n.IsExternal ,
                                       n.NavigationTypeListItemId ,
                                       n.Icon ,
                                       n.DisplayOrder ,
                                       n.ResourceId ,
                                       @UserPersonId
                                FROM   #n AS n
                                       LEFT JOIN dbo.Navigation AS n2 ON n2.Navigation = n.Navigation
                                                                         AND n2.URL = n.URL
                                WHERE  n2.NavigationId IS NULL;


                    UPDATE nav
                    SET    nav.ParentNavigationId = nn.NavigationId
                    FROM   #n AS n
                           INNER JOIN dbo.Navigation AS nn ON n.ParentNavigationName = nn.Navigation
                                                              AND n.ParentUrl = nn.URL
                           INNER JOIN dbo.Navigation AS nav ON n.Navigation = nav.Navigation
                                                               AND nav.URL = n.URL;
                    --WHERE  ISNULL (n.ParentUrl, '') = '';

                    --UPDATE nav
                    --SET    nav.ParentNavigationId = nn.NavigationId
                    --FROM   #Out AS o
                    --       INNER JOIN #n AS n ON n.Id = o.Id
                    --       INNER JOIN dbo.Navigation AS nn
                    --                  INNER JOIN dbo.Navigation AS pn ON pn.NavigationId = nn.ParentNavigationId ON n.ParentNavigationName = nn.Navigation
                    --                                                                                                AND n.ParentUrl = pn.Navigation
                    --       INNER JOIN dbo.Navigation AS nav ON o.NavigationId = nav.NavigationId
                    --WHERE  ISNULL (n.ParentUrl, '') <> '';


                    UPDATE nav
                    SET    nav.RootNavigationId = nn.NavigationId
                    FROM   #n AS n
                           INNER JOIN dbo.Navigation AS nn ON n.RootNavigationName = nn.Navigation
                           INNER JOIN dbo.Navigation AS nav ON n.Navigation = nav.Navigation
                                                               AND nav.URL = n.URL;

                    /*  UPDATE nav
                    SET    nav.ParentNavigationId = xyz.UpdNavigationId
                    FROM   dbo.Navigation AS nav
                           INNER JOIN (   SELECT pNav.NavigationId ,
                                                 pNav.Navigation ,
                                                 pNav.ParentNavigationName ,
                                                 nn.NavigationId AS UpdNavigationId
                                          FROM   (   SELECT o.NavigationId ,
                                                            n.Navigation ,
                                                            n.ParentNavigationName
                                                     FROM   #Out AS o
                                                            INNER JOIN #n AS n ON n.Id = o.Id ) AS pNav
                                                 LEFT JOIN dbo.Navigation AS nn ON pNav.ParentNavigationName = nn.Navigation ) AS xyz ON xyz.NavigationId = nav.NavigationId;

                    UPDATE n
                    SET    n.RootNavigationId = CASE WHEN n.ParentNavigationId IS NULL THEN
                                                         n.NavigationId
                                                ELSE n.ParentNavigationId
                                                END
                    FROM   dbo.Navigation AS n;
					*/

                    SELECT @Json = ( SELECT n2.NavigationId AS navigationId ,
                                            n.Navigation AS navigation ,
                                            n.URL AS uRL ,
                                            n.IsExternal AS isExternal ,
                                            n.ParentNavigationName AS parentNavigationName ,
                                            n.NavigationTypeListItemId AS navigationTypeListItemId ,
                                            n.RootNavigationName AS rootNavigationName ,
                                            n.Icon AS icon ,
                                            n.DisplayOrder AS displayOrder ,
                                            n.ResourceId AS resourceId
                                     FROM   #n AS n
                                            INNER JOIN dbo.Navigation AS n2 ON n2.Navigation = n.Navigation
                                   FOR JSON PATH, INCLUDE_NULL_VALUES );



                /*  IF ISNULL(@RootNavigationId, 0) = 0
            BEGIN
                UPDATE n
                SET n.RootNavigationId = #navigationId
                FROM dbo.Navigation AS n
                WHERE n.NavigationId = #navigationId
                      AND n.ParentNavigationId IS NULL;

                UPDATE o
                SET o.RootNavigationId = o2.RootNavigationId
                FROM dbo.Navigation o
                    INNER JOIN dbo.Navigation AS o2
                        ON o.ParentNavigationId = o2.NavigationId
                WHERE o.NavigationId = #navigationId
                      AND o.ParentNavigationId IS NOT NULL;
					  */

                END;

        END TRY
        BEGIN CATCH
            THROW;
        END CATCH;
    END;











GO
