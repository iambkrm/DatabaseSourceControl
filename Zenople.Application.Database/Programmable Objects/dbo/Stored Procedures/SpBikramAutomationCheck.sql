IF OBJECT_ID('[dbo].[SpBikramAutomationCheck]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpBikramAutomationCheck];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpBikramAutomationCheck]
		(@json NVARCHAR(MAX))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
			SELECT @json
END
GO
