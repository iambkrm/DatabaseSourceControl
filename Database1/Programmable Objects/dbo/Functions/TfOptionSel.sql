IF OBJECT_ID('[dbo].[TfOptionSel]') IS NOT NULL
	DROP FUNCTION [dbo].[TfOptionSel];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		samar
-- Create date: 01/10/2019
-- Description:	gets the list of listitem for office and category
-- ==============================

-- =============================================
-- Author:		Abinesh 
-- Create date: 01/16/2019
-- Description:	Modified and returned new fields DefaultValue
-- ==============================

CREATE FUNCTION [dbo].[TfOptionSel]
(   @Option VARCHAR (100) ,
    @OptionProperty VARCHAR (100) ,
    @Entity VARCHAR (25) ,
    @EntityId INT )
RETURNS @t TABLE
(   EntityOptionId INT ,
    OptionValue NVARCHAR (2000) ,
    DefaultValue NVARCHAR (1000) ,
    OptionPropertyId INT ,
    Entity VARCHAR (50))
AS
    BEGIN


        IF ( @Entity = 'Tenant' )
            BEGIN
                INSERT @t ( EntityOptionId ,
                            OptionValue ,
                            DefaultValue ,
                            OptionPropertyId ,
                            Entity )
                       SELECT ISNULL (oo.TenantOptionId, 0) ,
                              ISNULL (oo.OptionValue, op.DefaultValue) ,
                              op.DefaultValue ,
                              op.OptionPropertyId ,
                              li.ListItem
                       FROM   dbo.OptionProperty AS op
                              INNER JOIN dbo.[Option] AS o ON o.OptionId = op.OptionId
                              INNER JOIN dbo.ListItem AS li ON li.ListItemId = op.EntityListItemId
                              LEFT JOIN dbo.TenantOption AS oo ON  op.OptionPropertyId = oo.OptionPropertyId
                                                               AND oo.TenantId = @EntityId
                       WHERE  op.OptionProperty = @OptionProperty
                       AND    o.[Option] = @Option;
            END;
        IF ( @Entity = 'Office' )
            BEGIN
                INSERT @t ( EntityOptionId ,
                            OptionValue ,
                            DefaultValue ,
                            OptionPropertyId ,
                            Entity )
                       SELECT ISNULL (oo.OfficeOptionId, 0) ,
                              ISNULL (oo.OptionValue, op.DefaultValue) ,
                              op.DefaultValue ,
                              op.OptionPropertyId ,
                              li.ListItem
                       FROM   dbo.OptionProperty AS op
                              INNER JOIN dbo.[Option] AS o ON o.OptionId = op.OptionId
                              INNER JOIN dbo.ListItem AS li ON li.ListItemId = op.EntityListItemId
                              LEFT JOIN dbo.OfficeOption AS oo ON  op.OptionPropertyId = oo.OptionPropertyId
                                                               AND oo.OfficeId = @EntityId
                       WHERE  op.OptionProperty = @OptionProperty
                       AND    o.[Option] = @Option;

            END;

        IF ( @Entity = 'Organization' )
            BEGIN
                INSERT @t ( EntityOptionId ,
                            OptionValue ,
                            DefaultValue ,
                            OptionPropertyId ,
                            Entity )
                       SELECT ISNULL (oo.OrganizationOptionId, 0) ,
                              ISNULL (oo.OptionValue, op.DefaultValue) ,
                              op.DefaultValue ,
                              op.OptionPropertyId ,
                              li.ListItem
                       FROM   dbo.OptionProperty AS op
                              INNER JOIN dbo.[Option] AS o ON o.OptionId = op.OptionId
                              INNER JOIN dbo.ListItem AS li ON li.ListItemId = op.EntityListItemId
                              LEFT JOIN dbo.OrganizationOption AS oo ON  op.OptionPropertyId = oo.OptionPropertyId
                                                                     AND oo.OrganizationId = @EntityId
                       WHERE  op.OptionProperty = @OptionProperty
                       AND    o.[Option] = @Option;
            END;


        IF ( @Entity = 'Person' )
            BEGIN
                INSERT @t ( EntityOptionId ,
                            OptionValue ,
                            DefaultValue ,
                            OptionPropertyId ,
                            Entity )
                       SELECT ISNULL (oo.PersonOptionId, 0) ,
                              ISNULL (oo.OptionValue, op.DefaultValue) ,
                              op.DefaultValue ,
                              op.OptionPropertyId ,
                              li.ListItem
                       FROM   dbo.OptionProperty AS op
                              INNER JOIN dbo.[Option] AS o ON o.OptionId = op.OptionId
                              INNER JOIN dbo.ListItem AS li ON li.ListItemId = op.EntityListItemId
                              LEFT JOIN dbo.PersonOption AS oo ON  op.OptionPropertyId = oo.OptionPropertyId
                                                               AND oo.PersonId = @EntityId
                       WHERE  op.OptionProperty = @OptionProperty
                       AND    o.[Option] = @Option;

            END;
        IF ( @Entity = 'System' )
            BEGIN
                INSERT @t ( EntityOptionId ,
                            OptionValue ,
                            DefaultValue ,
                            OptionPropertyId ,
                            Entity )
                       SELECT ISNULL (oo.SystemOptionId, 0) ,
                              ISNULL (oo.OptionValue, op.DefaultValue) ,
                              op.DefaultValue ,
                              op.OptionPropertyId ,
                              li.ListItem
                       FROM   dbo.OptionProperty AS op
                              INNER JOIN dbo.[Option] AS o ON o.OptionId = op.OptionId
                              INNER JOIN dbo.ListItem AS li ON li.ListItemId = op.EntityListItemId
                              LEFT JOIN dbo.SystemOption AS oo ON  op.OptionPropertyId = oo.OptionPropertyId
                                                               AND oo.SystemId = @EntityId
                       WHERE  op.OptionProperty = @OptionProperty
                       AND    o.[Option] = @Option;
            END;


        RETURN;
    END;










GO
