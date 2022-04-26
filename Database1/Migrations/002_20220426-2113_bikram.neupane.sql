-- <Migration ID="b9fc20ba-2ed4-4e40-804e-cc226a5dca9b" />
GO

PRINT N'Altering [dbo].[OfficeOption]'
GO
ALTER TABLE [dbo].[OfficeOption] DROP
COLUMN [UserPersonId]
GO
PRINT N'Altering [dbo].[OfficeOptionHistoryLog] (this may be covered by an earlier temporal table alter)'
GO
