IF OBJECT_ID('[dbo].[SfResourceIdGet]') IS NOT NULL
	DROP FUNCTION [dbo].[SfResourceIdGet];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Mrijan
-- Create date: 08/25/2019
-- Description:	Gets the Unmapped Resource name from Resource
-- =============================================


CREATE FUNCTION [dbo].[SfResourceIdGet]
(
    @Resource VARCHAR(100)
)
RETURNS INT
AS
BEGIN

    DECLARE @ResourceId INT = 0;
    SELECT @ResourceId = r.ResourceId
    FROM dbo.Resource AS r
    WHERE r.Resource = @Resource;

    RETURN @ResourceId;
END;



GO
