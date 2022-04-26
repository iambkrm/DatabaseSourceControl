IF OBJECT_ID('[dbo].[SfSessionContextIdGet]') IS NOT NULL
	DROP FUNCTION [dbo].[SfSessionContextIdGet];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		samar
-- Create date: 05/11/2019
-- Description:	Gets the Id from ContextInfo
-- =============================================


CREATE FUNCTION [dbo].[SfSessionContextIdGet]
(
    @ContextKey NVARCHAR(50)
)
RETURNS INT
AS
BEGIN

    DECLARE @Id INT = 0;
    SELECT @Id = ISNULL(TRY_CONVERT(INT, SESSION_CONTEXT(LOWER(@ContextKey))), 0);
    RETURN @Id;

END;


GO
