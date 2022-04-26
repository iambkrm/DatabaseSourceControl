IF OBJECT_ID('[dbo].[SfRoleIdGet]') IS NOT NULL
	DROP FUNCTION [dbo].[SfRoleIdGet];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Smita
-- Create date: 08/16/2019
-- Description:	Gets the RoleId from Role
-- =============================================


CREATE FUNCTION [dbo].[SfRoleIdGet]
(
    @Role VARCHAR(25)
)
RETURNS INT
AS
BEGIN

    DECLARE @RoleId INT = 0;
    SELECT @RoleId = r.RoleId
    FROM dbo.Role AS r
    WHERE r.Role = @Role;

    RETURN @RoleId;
END;



GO
