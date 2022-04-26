CREATE TABLE [dbo].[OfficeOptionHistoryLog]
(
[OfficeOptionId] [int] NOT NULL,
[OfficeId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_OfficeOptionHistoryLog] ON [dbo].[OfficeOptionHistoryLog] ([EndPeriod], [StartPeriod])
GO
CREATE TABLE [dbo].[OfficeOption]
(
[OfficeOptionId] [int] NOT NULL IDENTITY(1, 1),
[OfficeId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_OfficeOption_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFOfficeOptionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFOfficeOptionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_OfficeOption] PRIMARY KEY CLUSTERED ([OfficeOptionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[OfficeOptionHistoryLog])
)
GO
ALTER TABLE [dbo].[OfficeOption] ADD CONSTRAINT [UkOfficeOptionOfficeIdOptionPropertyId] UNIQUE NONCLUSTERED ([OfficeId], [OptionPropertyId])
GO
ALTER TABLE [dbo].[OfficeOption] ADD CONSTRAINT [FK_OfficeOption_Office] FOREIGN KEY ([OfficeId]) REFERENCES [dbo].[Office] ([OfficeId])
GO
ALTER TABLE [dbo].[OfficeOption] ADD CONSTRAINT [FK_OfficeOption_OptionProperty] FOREIGN KEY ([OptionPropertyId]) REFERENCES [dbo].[OptionProperty] ([OptionPropertyId])
GO
