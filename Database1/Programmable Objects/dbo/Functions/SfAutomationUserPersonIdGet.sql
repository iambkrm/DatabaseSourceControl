IF OBJECT_ID('[dbo].[SfAutomationUserPersonIdGet]') IS NOT NULL
	DROP FUNCTION [dbo].[SfAutomationUserPersonIdGet];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Mrijan
-- Create date: 05/24/2020
-- Description:	Gets automation user personid
-- =============================================


CREATE FUNCTION [dbo].[SfAutomationUserPersonIdGet]
()
RETURNS INT
AS
    BEGIN

        DECLARE @AutomationUserPersonId INT;
        DECLARE @TenantId INT;
        SELECT @TenantId = t.TenantId
        FROM   dbo.Tenant AS t;

        SELECT @AutomationUserPersonId = tos.DefaultValue
        FROM   dbo.TfOptionSel ('Common', 'AutomationUser', 'Tenant', @TenantId) AS tos;

        RETURN @AutomationUserPersonId;

    END;


GO
