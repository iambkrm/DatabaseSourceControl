IF OBJECT_ID('[dbo].[SpOptionNewTsk]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpOptionNewTsk];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ===================================================================
-- Author      : mrijan.shrestha
-- Create date : 02/14/2019
-- Description : Inserts into tables realted to Option
-- ===================================================================
/*
dbo.[SpOptionNewTsk] @Json = '[{"option":"Invoicing",
"optionProperty":"DefaultTransactionGroupBy",
  "entity":"Person",
  "dataType":"select",
  "showInUI":1,
  "defaultValue":"AccountingPeriod",
  "source":"[PeriodEnding,AccountingPeriod,Office]",
  "description":" default",
  "tableName":null,
  "columnName":null
},{"option":"Invoicing",
  "optionProperty":"PaymentTerms",
  "entity":"Tenant",
  "dataType":"string",
  "showInUI":1,
  "defaultValue":"DueOnReceipt",
  "source":"[DueOnReceipt]",
  "description":"Payemnt term",
  "tableName":null,
  "columnName":null
}]'

*/

CREATE PROCEDURE [dbo].[SpOptionNewTsk]
(
    @Json VARCHAR (MAX))
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


                    EXEC dbo.SpOptionIns @Json = @Json OUTPUT;


                    EXEC dbo.SpOptionPropertyIns @Json = @Json OUTPUT;

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
