IF OBJECT_ID('[dbo].[SfApplicationIdGet]') IS NOT NULL
	DROP FUNCTION [dbo].[SfApplicationIdGet];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Smita
-- Create date: 08/16/2019
-- Description:	Gets the ApplicationId from Application
-- =============================================


CREATE FUNCTION [dbo].[SfApplicationIdGet]
(
    @Application VARCHAR(25)
)
RETURNS INT
AS
BEGIN

    DECLARE @ApplicationId INT = 0;
    IF (@Application IS NULL)
    BEGIN
        SELECT @ApplicationId = dbo.SfSessionContextIdGet(N'ApplicationId');
    END;
    ELSE
    BEGIN
        SELECT @ApplicationId = r.ApplicationId
        FROM dbo.Application AS r
        WHERE r.Application = @Application;
    END;

    RETURN @ApplicationId;
END;




GO
