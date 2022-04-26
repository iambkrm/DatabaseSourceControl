IF OBJECT_ID('[dbo].[SfPersonIdGet]') IS NOT NULL
	DROP FUNCTION [dbo].[SfPersonIdGet];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[SfPersonIdGet] ()
RETURNS INT
AS
BEGIN

DECLARE @PersonId INT = dbo.SfSessionContextIdGet(N'PersonId');
RETURN @PersonId;

END;


GO
