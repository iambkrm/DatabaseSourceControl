﻿/*
    This script was generated by SQL Change Automation to help provide object-level history. This script should never be edited manually.
    For more information see: https://www.red-gate.com/sca/dev/offline-schema-model
*/

CREATE TABLE [dbo].[ListItemHistoryLog]
(
[ListItemId] [int] NOT NULL,
[ListItem] [varchar] (50) NOT NULL,
[Description] [varchar] (200) NOT NULL,
[ListItemCategoryId] [int] NOT NULL,
[GLCode] [varchar] (25) NOT NULL,
[ResourceId] [int] NOT NULL,
[IsSystem] [bit] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_ListItemHistoryLog] ON [dbo].[ListItemHistoryLog] ([EndPeriod], [StartPeriod])
GO
CREATE TABLE [dbo].[ListItem]
(
[ListItemId] [int] NOT NULL IDENTITY(1, 1),
[ListItem] [varchar] (50) NOT NULL,
[Description] [varchar] (200) NOT NULL,
[ListItemCategoryId] [int] NOT NULL,
[GLCode] [varchar] (25) NOT NULL CONSTRAINT [DF_ListItem_GLCode] DEFAULT ('000'),
[ResourceId] [int] NOT NULL,
[IsSystem] [bit] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_ListItem_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFListItemStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFListItemEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_ListItem] PRIMARY KEY CLUSTERED ([ListItemId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ListItemHistoryLog])
)
GO
ALTER TABLE [dbo].[ListItem] ADD CONSTRAINT [UkListItemListItemCategoryIdListItem] UNIQUE NONCLUSTERED ([ListItemCategoryId], [ListItem])
GO
ALTER TABLE [dbo].[ListItem] ADD CONSTRAINT [FK_ListItem_ListItemCategory] FOREIGN KEY ([ListItemCategoryId]) REFERENCES [dbo].[ListItemCategory] ([ListItemCategoryId])
GO
