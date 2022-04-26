IF OBJECT_ID('[dbo].[SpOptionPropertyIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpOptionPropertyIns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : mrijan.shrestha
-- Create date : 08/29/2019
-- Description : Inserts into table OptionProperty
-- ===================================================================
-----Modified by Smita 4/1/2021 added ColumnName column
CREATE PROCEDURE [dbo].[SpOptionPropertyIns]
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

                    DECLARE @ot TABLE
                    (   OptionId INT ,
                        OptionProperty VARCHAR (100) ,
                        EntityListItemId INT ,
                        DataTypeListItemId INT ,
                        ShowInUI BIT ,
                        DefaultValue NVARCHAR (1000) ,
                        [Source] NVARCHAR (MAX) ,
                        TableName VARCHAR (100) ,
                        ColumnName VARCHAR (100) ,
                        [description] NVARCHAR (1000));

                    INSERT INTO @ot ( OptionId ,
                                      OptionProperty ,
                                      EntityListItemId ,
                                      DataTypeListItemId ,
                                      ShowInUI ,
                                      DefaultValue ,
                                      [Source] ,
                                      TableName ,
                                      ColumnName ,
                                      description )
                                SELECT oj.optionId ,
                                       oj.optionProperty ,
                                       oj.entityListItemId ,
                                       oj.dataTypeListItemId ,
                                       ISNULL (oj.showInUI, 0) ,
                                       oj.defaultValue ,
                                       oj.[source] ,
                                       ISNULL (oj.tableName, NULL) ,
                                       ISNULL (oj.columnName, NULL) ,
                                       ISNULL (oj.description, oj.optionProperty)
                                FROM
                                       OPENJSON (@Json)
                                           WITH ( optionId INT ,
                                                  optionProperty VARCHAR (100) ,
                                                  entityListItemId INT ,
                                                  dataTypeListItemId INT ,
                                                  showInUI BIT ,
                                                  defaultValue NVARCHAR (1000) ,
                                                  [source] NVARCHAR (MAX) ,
                                                  tableName VARCHAR (100) ,
                                                  columnName VARCHAR (100) ,
                                                  [description] NVARCHAR (1000)) AS oj;

                    INSERT INTO dbo.OptionProperty ( OptionId ,
                                                     OptionProperty ,
                                                     Description ,
                                                     EntityListItemId ,
                                                     DataTypeListItemId ,
                                                     ShowInUI ,
                                                     DefaultValue ,
                                                     [Source] ,
                                                     TableName ,
                                                     ColumnName ,
                                                     UserPersonId )
                                SELECT DISTINCT o.OptionId ,
                                                o.OptionProperty ,
                                                o.description ,
                                                o.EntityListItemId ,
                                                o.DataTypeListItemId ,
                                                o.ShowInUI ,
                                                o.DefaultValue ,
                                                o.[Source] ,
                                                o.TableName ,
                                                o.ColumnName ,
                                                @UserPersonId
                                FROM   @ot AS o
                                       LEFT JOIN dbo.OptionProperty AS op ON  op.OptionId = o.OptionId
                                                                          AND op.OptionProperty = o.OptionProperty
                                WHERE  op.OptionPropertyId IS NULL;

                    SELECT @Json = ( SELECT o.OptionId AS optionId ,
                                            y.OptionPropertyId AS optionPropertyId ,
                                            o.[Source] AS [source]
                                     FROM   @ot o
                                            INNER JOIN dbo.OptionProperty y ON y.OptionId = o.OptionId
                                     WHERE  y.OptionProperty = o.OptionProperty
                                   FOR JSON PATH, INCLUDE_NULL_VALUES );
                END;

        END TRY
        BEGIN CATCH
            THROW;
        END CATCH;
    END;








GO
