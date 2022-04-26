﻿/*
    This script was generated by SQL Change Automation to help provide object-level history. This script should never be edited manually.
    For more information see: https://www.red-gate.com/sca/dev/offline-schema-model
*/

CREATE TABLE [dbo].[ApplicationHistoryLog]
(
[ApplicationId] [int] NOT NULL,
[Application] [varchar] (50) NOT NULL,
[Description] [varchar] (200) NOT NULL,
[Icon] [varchar] (25) NOT NULL,
[ResourceId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL,
[SortOrder] [int] NOT NULL,
[ShowInUI] [bit] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_ApplicationHistoryLog] ON [dbo].[ApplicationHistoryLog] ([EndPeriod], [StartPeriod])
GO
CREATE TABLE [dbo].[Application]
(
[ApplicationId] [int] NOT NULL IDENTITY(1, 1),
[Application] [varchar] (50) NOT NULL,
[Description] [varchar] (200) NOT NULL,
[Icon] [varchar] (25) NOT NULL,
[ResourceId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Application_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFApplicationStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFApplicationEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
[SortOrder] [int] NOT NULL CONSTRAINT [DF__Applicati__SortO__74951777] DEFAULT ((999)),
[ShowInUI] [bit] NOT NULL CONSTRAINT [DF__Applicati__ShowI__1B64CBD5] DEFAULT ((1)),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Application] PRIMARY KEY CLUSTERED ([ApplicationId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ApplicationHistoryLog])
)
GO
ALTER TABLE [dbo].[Application] ADD CONSTRAINT [UkApplicationApplication] UNIQUE NONCLUSTERED ([Application])
GO
ALTER TABLE [dbo].[Application] ADD CONSTRAINT [FK_Application_Resource] FOREIGN KEY ([ResourceId]) REFERENCES [dbo].[Resource] ([ResourceId])
GO
