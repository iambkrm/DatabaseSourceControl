﻿/*
    This script was generated by SQL Change Automation to help provide object-level history. This script should never be edited manually.
    For more information see: https://www.red-gate.com/sca/dev/offline-schema-model
*/

CREATE TABLE [dbo].[ApplicationNavigationActionHistoryLog]
(
[ApplicationNavigationActionId] [int] NOT NULL,
[ApplicationId] [int] NOT NULL,
[NavigationActionId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_ApplicationNavigationActionHistoryLog] ON [dbo].[ApplicationNavigationActionHistoryLog] ([EndPeriod], [StartPeriod])
GO
CREATE TABLE [dbo].[ApplicationNavigationAction]
(
[ApplicationNavigationActionId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationId] [int] NOT NULL,
[NavigationActionId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_ApplicationNavigationAction_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFApplicationNavigationActionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFApplicationNavigationActionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_ApplicationNavigationAction] PRIMARY KEY CLUSTERED ([ApplicationNavigationActionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ApplicationNavigationActionHistoryLog])
)
GO
ALTER TABLE [dbo].[ApplicationNavigationAction] ADD CONSTRAINT [uk_ApplicationNavigationActionApplicationIdNavigationActionId] UNIQUE NONCLUSTERED ([ApplicationId], [NavigationActionId])
GO
ALTER TABLE [dbo].[ApplicationNavigationAction] ADD CONSTRAINT [FK_ApplicationNavigationAction_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
GO
ALTER TABLE [dbo].[ApplicationNavigationAction] ADD CONSTRAINT [FK_ApplicationNavigationAction_NavigationAction] FOREIGN KEY ([NavigationActionId]) REFERENCES [dbo].[NavigationAction] ([NavigationActionId])
GO
