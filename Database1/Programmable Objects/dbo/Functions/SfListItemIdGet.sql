IF OBJECT_ID('[dbo].[SfListItemIdGet]') IS NOT NULL
	DROP FUNCTION [dbo].[SfListItemIdGet];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Mrijan
-- Create date: 5/22/2019
-- Description:	Gets the ListItemId from ListItemCategory and ListItem
-- =============================================


CREATE FUNCTION [dbo].[SfListItemIdGet]
(
    @Category VARCHAR(50),
    @ListItem VARCHAR(50)
)
RETURNS INT
AS
BEGIN

    DECLARE @ListItemId INT = 0;

    SELECT @ListItemId = li.ListItemId
    FROM dbo.ListItem AS li
        INNER JOIN dbo.ListItemCategory AS lic
            ON li.ListItemCategoryId = lic.ListItemCategoryId
    WHERE lic.Category = @Category
          AND li.ListItem = @ListItem;

    RETURN ISNULL(@ListItemId, 0);

END;

GO
