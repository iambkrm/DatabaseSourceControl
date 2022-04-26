IF OBJECT_ID('[dbo].[SpOptionIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpOptionIns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : mrijan.shrestha
-- Create date : 02/14/2019
-- Description : Inserts into table Option
-- ===================================================================
-- Modified      : Sushant Dhakal
-- Create date : 01/12/2020
-- Description : Table name added  
-- ===================================================================
-- Modified  by    : Smita 4/1/2021 added ColumnName 
CREATE PROCEDURE [dbo].[SpOptionIns]
(
    @Json VARCHAR (MAX) OUTPUT )
AS
    BEGIN
        SET NOCOUNT ON;

        BEGIN TRY
            BEGIN TRANSACTION;
            DECLARE @UserPersonId INT = dbo.SfPersonIdGet ();
            IF ( @UserPersonId = 0 )
                BEGIN
                    RAISERROR ('Insert person not found.', 16, 1);
                END;

            ELSE
                BEGIN

                    DECLARE @ot TABLE
                    (   [Option] VARCHAR (100) ,
                        OptionProperty VARCHAR (100) ,
                        EntityListItemId INT ,
                        DataTypeListItemId INT ,
                        ShowInUI BIT ,
                        DefaultValue VARCHAR (1000) ,
                        [Source] VARCHAR (MAX) ,
                        TableName VARCHAR (100) ,
                        ColumnName VARCHAR (100) ,
                        [description] NVARCHAR (1000));

                    INSERT INTO @ot ( [Option] ,
                                      OptionProperty ,
                                      EntityListItemId ,
                                      DataTypeListItemId ,
                                      ShowInUI ,
                                      DefaultValue ,
                                      [Source] ,
                                      TableName ,
                                      ColumnName ,
                                      description )
                                SELECT oj.[option] ,
                                       oj.optionProperty ,
                                       li.ListItemId ,
                                       li2.ListItemId ,
                                       oj.showInUI ,
                                       oj.defaultValue ,
                                       oj.[source] ,
                                       oj.tableName ,
                                       oj.columnName ,
                                       ISNULL (oj.description, oj.optionProperty)
                                FROM
                                       OPENJSON (@Json)
                                           WITH ( [option] VARCHAR (100) ,
                                                  optionProperty VARCHAR (100) ,
                                                  entity VARCHAR (50) ,
                                                  dataType VARCHAR (50) ,
                                                  showInUI BIT ,
                                                  defaultValue VARCHAR (1000) ,
                                                  [source] VARCHAR (MAX) ,
                                                  tableName VARCHAR (100) ,
                                                  columnName VARCHAR (100) ,
                                                  [description] NVARCHAR (1000)) AS oj
                                       LEFT JOIN dbo.ListItem AS li ON li.ListItem = oj.entity
                                       INNER JOIN dbo.ListItemCategory AS lic ON  lic.ListItemCategoryId = li.ListItemCategoryId
                                                                              AND lic.Category = 'Entity'
                                       LEFT JOIN dbo.ListItem AS li2 ON li2.ListItem = oj.dataType
                                       INNER JOIN dbo.ListItemCategory AS lic2 ON  lic2.ListItemCategoryId = li2.ListItemCategoryId
                                                                               AND lic2.Category = 'DataType';


                    INSERT INTO dbo.[Option] ( [Option] ,
                                               UserPersonId )
                                SELECT DISTINCT oj.[Option] ,
                                                @UserPersonId
                                FROM   @ot AS oj
                                       LEFT JOIN dbo.[Option] AS o ON o.[Option] = oj.[Option]
                                WHERE  o.OptionId IS NULL;

                    SELECT @Json = ( SELECT o2.OptionId AS optionId ,
                                            o.OptionProperty AS optionProperty ,
                                            o.EntityListItemId AS entityListItemId ,
                                            o.DataTypeListItemId AS dataTypeListItemId ,
                                            o.ShowInUI AS showInUI ,
                                            o.DefaultValue AS defaultValue ,
                                            o.[Source] AS [source] ,
                                            o.TableName AS tableName ,
                                            o.ColumnName AS columnName ,
                                            o.[description]
                                     FROM   @ot o
                                            INNER JOIN dbo.[Option] AS o2 ON o2.[Option] = o.[Option]
                                   FOR JSON PATH, INCLUDE_NULL_VALUES );


                END;
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;












GO
