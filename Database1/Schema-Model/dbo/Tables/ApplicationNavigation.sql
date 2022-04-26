﻿/*
    This script was generated by SQL Change Automation to help provide object-level history. This script should never be edited manually.
    For more information see: https://www.red-gate.com/sca/dev/offline-schema-model
*/

CREATE TABLE [dbo].[ApplicationNavigationHistoryLog]
(
[ApplicationNavigationId] [int] NOT NULL,
[ApplicationId] [int] NOT NULL,
[NavigationId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL,
[ParentApplicationId] [int] NULL
)
GO
CREATE CLUSTERED INDEX [ix_ApplicationNavigationHistoryLog] ON [dbo].[ApplicationNavigationHistoryLog] ([EndPeriod], [StartPeriod])
GO
CREATE TABLE [dbo].[ApplicationNavigation]
(
[ApplicationNavigationId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationId] [int] NOT NULL,
[NavigationId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_ApplicationNavigation_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFApplicationNavigationStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFApplicationNavigationEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
[ParentApplicationId] [int] NULL,
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_ApplicationNavigation] PRIMARY KEY CLUSTERED ([ApplicationNavigationId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ApplicationNavigationHistoryLog])
)
GO
ALTER TABLE [dbo].[ApplicationNavigation] ADD CONSTRAINT [uk_ApplicationNavigationApplicationIdNavigationId] UNIQUE NONCLUSTERED ([ApplicationId], [NavigationId])
GO
ALTER TABLE [dbo].[ApplicationNavigation] ADD CONSTRAINT [FK_ApplicationNavigation_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
GO
ALTER TABLE [dbo].[ApplicationNavigation] ADD CONSTRAINT [FK_ApplicationNavigation_Application2] FOREIGN KEY ([ParentApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
GO
ALTER TABLE [dbo].[ApplicationNavigation] ADD CONSTRAINT [FK_ApplicationNavigation_Navigation] FOREIGN KEY ([NavigationId]) REFERENCES [dbo].[Navigation] ([NavigationId])
GO
