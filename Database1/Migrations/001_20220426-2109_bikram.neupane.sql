-- <Migration ID="c52d8e79-ae6c-4e16-9886-a061ee23e43b" TransactionHandling="Custom" />
GO

PRINT N'Creating full text catalogs'
GO
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name = N'FullTextOrganizationCatalog')
CREATE FULLTEXT CATALOG [FullTextOrganizationCatalog]
WITH ACCENT_SENSITIVITY = ON
AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name = N'FullTextPersonAdditional')
CREATE FULLTEXT CATALOG [FullTextPersonAdditional]
WITH ACCENT_SENSITIVITY = ON
AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name = N'FullTextPersonCatalog')
CREATE FULLTEXT CATALOG [FullTextPersonCatalog]
WITH ACCENT_SENSITIVITY = OFF
AUTHORIZATION [dbo]
GO
PRINT N'Creating schemas'
GO
IF SCHEMA_ID(N'utl') IS NULL
EXEC sp_executesql N'CREATE SCHEMA [utl]
AUTHORIZATION [dbo]'
GO
PRINT N'Creating [dbo].[Resource]'
GO
IF OBJECT_ID(N'[dbo].[ResourceHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[ResourceHistoryLog]
(
[ResourceId] [int] NOT NULL,
[Resource] [nvarchar] (250) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_ResourceHistoryLog] on [dbo].[ResourceHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ResourceHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ResourceHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ResourceHistoryLog] ON [dbo].[ResourceHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Resource]', 'U') IS NULL
CREATE TABLE [dbo].[Resource]
(
[ResourceId] [int] NOT NULL IDENTITY(1, 1),
[Resource] [nvarchar] (250) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Resource_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFResourceStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFResourceEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Resource] PRIMARY KEY CLUSTERED ([ResourceId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ResourceHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[Resource]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkResourceResource]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[Resource]', 'U'))
ALTER TABLE [dbo].[Resource] ADD CONSTRAINT [UkResourceResource] UNIQUE NONCLUSTERED ([Resource])
GO
PRINT N'Creating [dbo].[Application]'
GO
IF OBJECT_ID(N'[dbo].[ApplicationHistoryLog]', 'U') IS NULL
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
PRINT N'Creating index [ix_ApplicationHistoryLog] on [dbo].[ApplicationHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ApplicationHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ApplicationHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ApplicationHistoryLog] ON [dbo].[ApplicationHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Application]', 'U') IS NULL
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
PRINT N'Adding constraints to [dbo].[Application]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkApplicationApplication]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[Application]', 'U'))
ALTER TABLE [dbo].[Application] ADD CONSTRAINT [UkApplicationApplication] UNIQUE NONCLUSTERED ([Application])
GO
PRINT N'Creating [dbo].[ApplicationNavigation]'
GO
IF OBJECT_ID(N'[dbo].[ApplicationNavigationHistoryLog]', 'U') IS NULL
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
PRINT N'Creating index [ix_ApplicationNavigationHistoryLog] on [dbo].[ApplicationNavigationHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ApplicationNavigationHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ApplicationNavigationHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ApplicationNavigationHistoryLog] ON [dbo].[ApplicationNavigationHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[ApplicationNavigation]', 'U') IS NULL
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
PRINT N'Adding constraints to [dbo].[ApplicationNavigation]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uk_ApplicationNavigationApplicationIdNavigationId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationNavigation]', 'U'))
ALTER TABLE [dbo].[ApplicationNavigation] ADD CONSTRAINT [uk_ApplicationNavigationApplicationIdNavigationId] UNIQUE NONCLUSTERED ([ApplicationId], [NavigationId])
GO
PRINT N'Creating [dbo].[Navigation]'
GO
IF OBJECT_ID(N'[dbo].[NavigationHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[NavigationHistoryLog]
(
[NavigationId] [int] NOT NULL,
[Navigation] [nvarchar] (100) NOT NULL,
[URL] [varchar] (50) NOT NULL,
[IsExternal] [bit] NOT NULL,
[NavigationTypeListItemId] [int] NOT NULL,
[ParentNavigationId] [int] NULL,
[RootNavigationId] [int] NULL,
[Icon] [varchar] (25) NULL,
[DisplayOrder] [int] NOT NULL,
[ResourceId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_NavigationHistoryLog] on [dbo].[NavigationHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_NavigationHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[NavigationHistoryLog]'))
CREATE CLUSTERED INDEX [ix_NavigationHistoryLog] ON [dbo].[NavigationHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Navigation]', 'U') IS NULL
CREATE TABLE [dbo].[Navigation]
(
[NavigationId] [int] NOT NULL IDENTITY(1, 1),
[Navigation] [nvarchar] (100) NOT NULL,
[URL] [varchar] (50) NOT NULL CONSTRAINT [DF_Navigation_URL] DEFAULT ('/home'),
[IsExternal] [bit] NOT NULL CONSTRAINT [DF_Navigation_IsExternal] DEFAULT ((1)),
[NavigationTypeListItemId] [int] NOT NULL,
[ParentNavigationId] [int] NULL,
[RootNavigationId] [int] NULL,
[Icon] [varchar] (25) NULL,
[DisplayOrder] [int] NOT NULL,
[ResourceId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Navigation_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFNavigationStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFNavigationEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Navigation] PRIMARY KEY CLUSTERED ([NavigationId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[NavigationHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[Navigation]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkNavigationURL]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[Navigation]', 'U'))
ALTER TABLE [dbo].[Navigation] ADD CONSTRAINT [UkNavigationURL] UNIQUE NONCLUSTERED ([URL])
GO
PRINT N'Creating [dbo].[ApplicationNavigationAction]'
GO
IF OBJECT_ID(N'[dbo].[ApplicationNavigationActionHistoryLog]', 'U') IS NULL
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
PRINT N'Creating index [ix_ApplicationNavigationActionHistoryLog] on [dbo].[ApplicationNavigationActionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ApplicationNavigationActionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ApplicationNavigationActionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ApplicationNavigationActionHistoryLog] ON [dbo].[ApplicationNavigationActionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[ApplicationNavigationAction]', 'U') IS NULL
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
PRINT N'Adding constraints to [dbo].[ApplicationNavigationAction]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uk_ApplicationNavigationActionApplicationIdNavigationActionId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationNavigationAction]', 'U'))
ALTER TABLE [dbo].[ApplicationNavigationAction] ADD CONSTRAINT [uk_ApplicationNavigationActionApplicationIdNavigationActionId] UNIQUE NONCLUSTERED ([ApplicationId], [NavigationActionId])
GO
PRINT N'Creating [dbo].[NavigationAction]'
GO
IF OBJECT_ID(N'[dbo].[NavigationActionHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[NavigationActionHistoryLog]
(
[NavigationActionId] [int] NOT NULL,
[NavigationId] [int] NOT NULL,
[Action] [nvarchar] (50) NOT NULL,
[Description] [nvarchar] (200) NOT NULL,
[NavigationActionTypeListItemId] [int] NOT NULL,
[ResourceId] [int] NOT NULL,
[Icon] [varchar] (25) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_NavigationActionHistoryLog] on [dbo].[NavigationActionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_NavigationActionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[NavigationActionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_NavigationActionHistoryLog] ON [dbo].[NavigationActionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[NavigationAction]', 'U') IS NULL
CREATE TABLE [dbo].[NavigationAction]
(
[NavigationActionId] [int] NOT NULL IDENTITY(1, 1),
[NavigationId] [int] NOT NULL,
[Action] [nvarchar] (50) NOT NULL,
[Description] [nvarchar] (200) NOT NULL,
[NavigationActionTypeListItemId] [int] NOT NULL,
[ResourceId] [int] NOT NULL,
[Icon] [varchar] (25) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_NavigationAction_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFNavigationActionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFNavigationActionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_NavigationAction] PRIMARY KEY CLUSTERED ([NavigationActionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[NavigationActionHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[NavigationAction]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkNavigationActionNavigationIdAction]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[NavigationAction]', 'U'))
ALTER TABLE [dbo].[NavigationAction] ADD CONSTRAINT [UkNavigationActionNavigationIdAction] UNIQUE NONCLUSTERED ([NavigationId], [Action])
GO
PRINT N'Creating [dbo].[ApplicationRole]'
GO
IF OBJECT_ID(N'[dbo].[ApplicationRoleHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[ApplicationRoleHistoryLog]
(
[ApplicationRoleId] [int] NOT NULL,
[ApplicationId] [int] NOT NULL,
[RoleId] [int] NOT NULL,
[NavigationId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_ApplicationRoleHistoryLog] on [dbo].[ApplicationRoleHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ApplicationRoleHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ApplicationRoleHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ApplicationRoleHistoryLog] ON [dbo].[ApplicationRoleHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[ApplicationRole]', 'U') IS NULL
CREATE TABLE [dbo].[ApplicationRole]
(
[ApplicationRoleId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationId] [int] NOT NULL,
[RoleId] [int] NOT NULL,
[NavigationId] [int] NOT NULL CONSTRAINT [DF__Applicati__Navig__21D92E4A] DEFAULT ((1)),
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_ApplicationRole_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFApplicationRoleStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFApplicationRoleEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_ApplicationRole] PRIMARY KEY CLUSTERED ([ApplicationRoleId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ApplicationRoleHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[ApplicationRole]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UKApplicationRoleApplicationIdRoleId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRole]', 'U'))
ALTER TABLE [dbo].[ApplicationRole] ADD CONSTRAINT [UKApplicationRoleApplicationIdRoleId] UNIQUE NONCLUSTERED ([ApplicationId], [RoleId])
GO
PRINT N'Creating [dbo].[Role]'
GO
IF OBJECT_ID(N'[dbo].[RoleHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[RoleHistoryLog]
(
[RoleId] [int] NOT NULL,
[Role] [varchar] (25) NOT NULL,
[StatusListItemId] [int] NOT NULL,
[ResourceId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL,
[Description] [varchar] (200) NULL
)
GO
PRINT N'Creating index [ix_RoleHistoryLog] on [dbo].[RoleHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_RoleHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[RoleHistoryLog]'))
CREATE CLUSTERED INDEX [ix_RoleHistoryLog] ON [dbo].[RoleHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Role]', 'U') IS NULL
CREATE TABLE [dbo].[Role]
(
[RoleId] [int] NOT NULL IDENTITY(1, 1),
[Role] [varchar] (25) NOT NULL,
[StatusListItemId] [int] NOT NULL,
[ResourceId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Role_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFRoleStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFRoleEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
[Description] [varchar] (200) NULL,
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([RoleId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[RoleHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[Role]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkRoleRole]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[Role]', 'U'))
ALTER TABLE [dbo].[Role] ADD CONSTRAINT [UkRoleRole] UNIQUE NONCLUSTERED ([Role])
GO
PRINT N'Creating [dbo].[ApplicationRoleNavigation]'
GO
IF OBJECT_ID(N'[dbo].[ApplicationRoleNavigationHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[ApplicationRoleNavigationHistoryLog]
(
[ApplicationRoleNavigationId] [int] NOT NULL,
[ApplicationRoleId] [int] NOT NULL,
[NavigationId] [int] NOT NULL,
[DisplayOrder] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_ApplicationRoleNavigationHistoryLog] on [dbo].[ApplicationRoleNavigationHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ApplicationRoleNavigationHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ApplicationRoleNavigationHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ApplicationRoleNavigationHistoryLog] ON [dbo].[ApplicationRoleNavigationHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[ApplicationRoleNavigation]', 'U') IS NULL
CREATE TABLE [dbo].[ApplicationRoleNavigation]
(
[ApplicationRoleNavigationId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationRoleId] [int] NOT NULL,
[NavigationId] [int] NOT NULL,
[DisplayOrder] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_ApplicationRoleNavigation_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFApplicationRoleNavigationStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFApplicationRoleNavigationEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_ApplicationRoleNavigation] PRIMARY KEY CLUSTERED ([ApplicationRoleNavigationId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ApplicationRoleNavigationHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[ApplicationRoleNavigation]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkApplicationRoleNavigationApplicationRoleIdNavigationId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRoleNavigation]', 'U'))
ALTER TABLE [dbo].[ApplicationRoleNavigation] ADD CONSTRAINT [UkApplicationRoleNavigationApplicationRoleIdNavigationId] UNIQUE NONCLUSTERED ([ApplicationRoleId], [NavigationId])
GO
PRINT N'Creating [dbo].[ApplicationRoleNavigationAction]'
GO
IF OBJECT_ID(N'[dbo].[ApplicationRoleNavigationActionHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[ApplicationRoleNavigationActionHistoryLog]
(
[ApplicationRoleNavigationActionId] [int] NOT NULL,
[ApplicationRoleId] [int] NOT NULL,
[NavigationActionId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_ApplicationRoleNavigationActionHistoryLog] on [dbo].[ApplicationRoleNavigationActionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ApplicationRoleNavigationActionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ApplicationRoleNavigationActionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ApplicationRoleNavigationActionHistoryLog] ON [dbo].[ApplicationRoleNavigationActionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[ApplicationRoleNavigationAction]', 'U') IS NULL
CREATE TABLE [dbo].[ApplicationRoleNavigationAction]
(
[ApplicationRoleNavigationActionId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationRoleId] [int] NOT NULL,
[NavigationActionId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_ApplicationRoleNavigationAction_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFApplicationRoleNavigationActionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFApplicationRoleNavigationActionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_ApplicationRoleNavigationAction] PRIMARY KEY CLUSTERED ([ApplicationRoleNavigationActionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ApplicationRoleNavigationActionHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[ApplicationRoleNavigationAction]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkApplicationRoleNavigationActionApplicationRoleIdNavigationActionId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRoleNavigationAction]', 'U'))
ALTER TABLE [dbo].[ApplicationRoleNavigationAction] ADD CONSTRAINT [UkApplicationRoleNavigationActionApplicationRoleIdNavigationActionId] UNIQUE NONCLUSTERED ([ApplicationRoleId], [NavigationActionId])
GO
PRINT N'Creating [dbo].[ListItemCategory]'
GO
IF OBJECT_ID(N'[dbo].[ListItemCategoryHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[ListItemCategoryHistoryLog]
(
[ListItemCategoryId] [int] NOT NULL,
[IsSystem] [bit] NOT NULL,
[Category] [varchar] (50) NOT NULL,
[Description] [varchar] (200) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_ListItemCategoryHistoryLog] on [dbo].[ListItemCategoryHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ListItemCategoryHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ListItemCategoryHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ListItemCategoryHistoryLog] ON [dbo].[ListItemCategoryHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[ListItemCategory]', 'U') IS NULL
CREATE TABLE [dbo].[ListItemCategory]
(
[ListItemCategoryId] [int] NOT NULL IDENTITY(1, 1),
[IsSystem] [bit] NOT NULL CONSTRAINT [DF_ListItemCategory_IsSystem] DEFAULT ((0)),
[Category] [varchar] (50) NOT NULL,
[Description] [varchar] (200) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_ListItemCategory_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFListItemCategoryStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFListItemCategoryEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_ListItemCategory] PRIMARY KEY CLUSTERED ([ListItemCategoryId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[ListItemCategoryHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[ListItemCategory]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkListItemCategoryCategory]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[ListItemCategory]', 'U'))
ALTER TABLE [dbo].[ListItemCategory] ADD CONSTRAINT [UkListItemCategoryCategory] UNIQUE NONCLUSTERED ([Category])
GO
PRINT N'Creating [dbo].[ListItem]'
GO
IF OBJECT_ID(N'[dbo].[ListItemHistoryLog]', 'U') IS NULL
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
PRINT N'Creating index [ix_ListItemHistoryLog] on [dbo].[ListItemHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_ListItemHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[ListItemHistoryLog]'))
CREATE CLUSTERED INDEX [ix_ListItemHistoryLog] ON [dbo].[ListItemHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[ListItem]', 'U') IS NULL
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
PRINT N'Adding constraints to [dbo].[ListItem]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkListItemListItemCategoryIdListItem]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[ListItem]', 'U'))
ALTER TABLE [dbo].[ListItem] ADD CONSTRAINT [UkListItemListItemCategoryIdListItem] UNIQUE NONCLUSTERED ([ListItemCategoryId], [ListItem])
GO
PRINT N'Creating [dbo].[NavigationNode]'
GO
IF OBJECT_ID(N'[dbo].[NavigationNodeHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[NavigationNodeHistoryLog]
(
[NavigationNodeId] [int] NOT NULL,
[NavigationId] [int] NOT NULL,
[NodeId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_NavigationNodeHistoryLog] on [dbo].[NavigationNodeHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_NavigationNodeHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[NavigationNodeHistoryLog]'))
CREATE CLUSTERED INDEX [ix_NavigationNodeHistoryLog] ON [dbo].[NavigationNodeHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[NavigationNode]', 'U') IS NULL
CREATE TABLE [dbo].[NavigationNode]
(
[NavigationNodeId] [int] NOT NULL IDENTITY(1, 1),
[NavigationId] [int] NOT NULL,
[NodeId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_NavigationNode_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFNavigationNodeStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFNavigationNodeEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_NavigationNode] PRIMARY KEY CLUSTERED ([NavigationNodeId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[NavigationNodeHistoryLog])
)
GO
PRINT N'Creating [dbo].[Node]'
GO
IF OBJECT_ID(N'[dbo].[NodeHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[NodeHistoryLog]
(
[NodeId] [int] NOT NULL,
[NodeTypeId] [int] NOT NULL,
[ParentNodeId] [int] NULL,
[RootNodeId] [int] NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_NodeHistoryLog] on [dbo].[NodeHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_NodeHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[NodeHistoryLog]'))
CREATE CLUSTERED INDEX [ix_NodeHistoryLog] ON [dbo].[NodeHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Node]', 'U') IS NULL
CREATE TABLE [dbo].[Node]
(
[NodeId] [int] NOT NULL IDENTITY(1, 1),
[NodeTypeId] [int] NOT NULL,
[ParentNodeId] [int] NULL,
[RootNodeId] [int] NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Node_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFNodeStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFNodeEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Node] PRIMARY KEY CLUSTERED ([NodeId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[NodeHistoryLog])
)
GO
PRINT N'Creating [dbo].[NodeType]'
GO
IF OBJECT_ID(N'[dbo].[NodeTypeHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[NodeTypeHistoryLog]
(
[NodeTypeId] [int] NOT NULL,
[NodeType] [varchar] (25) NOT NULL,
[ParentNodeTypeId] [int] NULL,
[RootNodeTypeId] [int] NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_NodeTypeHistoryLog] on [dbo].[NodeTypeHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_NodeTypeHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[NodeTypeHistoryLog]'))
CREATE CLUSTERED INDEX [ix_NodeTypeHistoryLog] ON [dbo].[NodeTypeHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[NodeType]', 'U') IS NULL
CREATE TABLE [dbo].[NodeType]
(
[NodeTypeId] [int] NOT NULL IDENTITY(1, 1),
[NodeType] [varchar] (25) NOT NULL,
[ParentNodeTypeId] [int] NULL,
[RootNodeTypeId] [int] NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_NodeType_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFNodeTypeStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFNodeTypeEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_NodeType] PRIMARY KEY CLUSTERED ([NodeTypeId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[NodeTypeHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[NodeType]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkNodeTypeNodeType]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[NodeType]', 'U'))
ALTER TABLE [dbo].[NodeType] ADD CONSTRAINT [UkNodeTypeNodeType] UNIQUE NONCLUSTERED ([NodeType])
GO
PRINT N'Creating [dbo].[Office]'
GO
IF OBJECT_ID(N'[dbo].[OfficeHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[OfficeHistoryLog]
(
[OfficeId] [int] NOT NULL,
[OrganizationId] [int] NOT NULL,
[Office] [nvarchar] (100) NOT NULL,
[OfficeTypeListItemId] [int] NOT NULL,
[NodeId] [int] NOT NULL,
[StatusListItemId] [int] NOT NULL,
[GLCode] [varchar] (25) NOT NULL,
[RootOfficeId] [int] NULL,
[ParentOfficeId] [int] NULL,
[IsIncludeInPortal] [bit] NOT NULL,
[BackOfficeId] [int] NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[ReferenceId] [varchar] (50) NULL,
[ReferenceNote] [varchar] (100) NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL,
[PortalName] [nvarchar] (100) NOT NULL
)
GO
PRINT N'Creating index [ix_OfficeHistoryLog] on [dbo].[OfficeHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_OfficeHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[OfficeHistoryLog]'))
CREATE CLUSTERED INDEX [ix_OfficeHistoryLog] ON [dbo].[OfficeHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Office]', 'U') IS NULL
CREATE TABLE [dbo].[Office]
(
[OfficeId] [int] NOT NULL IDENTITY(1, 1),
[OrganizationId] [int] NOT NULL,
[Office] [nvarchar] (100) NOT NULL,
[OfficeTypeListItemId] [int] NOT NULL,
[NodeId] [int] NOT NULL,
[StatusListItemId] [int] NOT NULL,
[GLCode] [varchar] (25) NOT NULL CONSTRAINT [DF_Office_GLCode] DEFAULT ('000'),
[RootOfficeId] [int] NULL,
[ParentOfficeId] [int] NULL,
[IsIncludeInPortal] [bit] NOT NULL CONSTRAINT [DF_Office_IsIncludeInPortal] DEFAULT ((1)),
[BackOfficeId] [int] NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Office_InsertDate] DEFAULT (getdate()),
[ReferenceId] [varchar] (50) NULL,
[ReferenceNote] [varchar] (100) NULL,
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFOfficeStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFOfficeEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
[PortalName] [nvarchar] (100) NOT NULL CONSTRAINT [DF__Office__PortalNa__38B5379A] DEFAULT (''),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Office] PRIMARY KEY CLUSTERED ([OfficeId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[OfficeHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[Office]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UKOfficeOrganizationIdOffice]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[Office]', 'U'))
ALTER TABLE [dbo].[Office] ADD CONSTRAINT [UKOfficeOrganizationIdOffice] UNIQUE NONCLUSTERED ([OrganizationId], [Office])
GO
PRINT N'Creating [dbo].[TenantOrganization]'
GO
IF OBJECT_ID(N'[dbo].[TenantOrganizationHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[TenantOrganizationHistoryLog]
(
[OrganizationId] [int] NOT NULL,
[TenantId] [int] NOT NULL,
[OfficeId] [int] NULL,
[Alias] [varchar] (15) NOT NULL,
[DBA] [nvarchar] (100) NULL,
[FEIN] [varchar] (25) NULL,
[NodeId] [int] NOT NULL,
[StatusListItemId] [int] NOT NULL,
[GLCode] [varchar] (25) NOT NULL,
[ServiceTypeListItemId] [int] NOT NULL,
[NextInvoiceNumber] [int] NOT NULL,
[CompanyProfile] [varchar] (max) NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[ReferenceId] [varchar] (50) NULL,
[ReferenceNote] [varchar] (100) NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_TenantOrganizationHistoryLog] on [dbo].[TenantOrganizationHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_TenantOrganizationHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[TenantOrganizationHistoryLog]'))
CREATE CLUSTERED INDEX [ix_TenantOrganizationHistoryLog] ON [dbo].[TenantOrganizationHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[TenantOrganization]', 'U') IS NULL
CREATE TABLE [dbo].[TenantOrganization]
(
[OrganizationId] [int] NOT NULL,
[TenantId] [int] NOT NULL,
[OfficeId] [int] NULL,
[Alias] [varchar] (15) NOT NULL,
[DBA] [nvarchar] (100) NULL,
[FEIN] [varchar] (25) NULL,
[NodeId] [int] NOT NULL,
[StatusListItemId] [int] NOT NULL,
[GLCode] [varchar] (25) NOT NULL CONSTRAINT [DF_TenantOrganization_GLCode] DEFAULT ('000'),
[ServiceTypeListItemId] [int] NOT NULL CONSTRAINT [DF_TenantOrganization_ServiceTypeListItemId] DEFAULT ((0)),
[NextInvoiceNumber] [int] NOT NULL,
[CompanyProfile] [varchar] (max) NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_TenantOrganization_InsertDate] DEFAULT (getdate()),
[ReferenceId] [varchar] (50) NULL,
[ReferenceNote] [varchar] (100) NULL,
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFTenantOrganizationStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFTenantOrganizationEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_TenantOrganization] PRIMARY KEY CLUSTERED ([OrganizationId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[TenantOrganizationHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[TenantOrganization]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkTenantOrganizationAlias]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[TenantOrganization]', 'U'))
ALTER TABLE [dbo].[TenantOrganization] ADD CONSTRAINT [UkTenantOrganizationAlias] UNIQUE NONCLUSTERED ([Alias])
GO
PRINT N'Creating [dbo].[OfficeOption]'
GO
IF OBJECT_ID(N'[dbo].[OfficeOptionHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[OfficeOptionHistoryLog]
(
[OfficeOptionId] [int] NOT NULL,
[OfficeId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_OfficeOptionHistoryLog] on [dbo].[OfficeOptionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_OfficeOptionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[OfficeOptionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_OfficeOptionHistoryLog] ON [dbo].[OfficeOptionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[OfficeOption]', 'U') IS NULL
CREATE TABLE [dbo].[OfficeOption]
(
[OfficeOptionId] [int] NOT NULL IDENTITY(1, 1),
[OfficeId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
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
PRINT N'Adding constraints to [dbo].[OfficeOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkOfficeOptionOfficeIdOptionPropertyId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[OfficeOption]', 'U'))
ALTER TABLE [dbo].[OfficeOption] ADD CONSTRAINT [UkOfficeOptionOfficeIdOptionPropertyId] UNIQUE NONCLUSTERED ([OfficeId], [OptionPropertyId])
GO
PRINT N'Creating [dbo].[OptionProperty]'
GO
IF OBJECT_ID(N'[dbo].[OptionPropertyHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[OptionPropertyHistoryLog]
(
[OptionPropertyId] [int] NOT NULL,
[OptionId] [int] NOT NULL,
[OptionProperty] [varchar] (100) NOT NULL,
[EntityListItemId] [int] NOT NULL,
[DataTypeListItemId] [int] NOT NULL,
[ShowInUI] [bit] NOT NULL,
[DefaultValue] [nvarchar] (1000) NOT NULL,
[Source] [nvarchar] (max) NOT NULL,
[TableName] [varchar] (100) NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL,
[Description] [nvarchar] (1000) NOT NULL,
[ColumnName] [varchar] (100) NULL
)
GO
PRINT N'Creating index [ix_OptionPropertyHistoryLog] on [dbo].[OptionPropertyHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_OptionPropertyHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[OptionPropertyHistoryLog]'))
CREATE CLUSTERED INDEX [ix_OptionPropertyHistoryLog] ON [dbo].[OptionPropertyHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[OptionProperty]', 'U') IS NULL
CREATE TABLE [dbo].[OptionProperty]
(
[OptionPropertyId] [int] NOT NULL IDENTITY(1, 1),
[OptionId] [int] NOT NULL,
[OptionProperty] [varchar] (100) NOT NULL,
[EntityListItemId] [int] NOT NULL,
[DataTypeListItemId] [int] NOT NULL CONSTRAINT [DF_OptionProperty_DataTyleListItemId] DEFAULT ((1)),
[ShowInUI] [bit] NOT NULL CONSTRAINT [DF_OptionProperty_ShowInUI] DEFAULT ((0)),
[DefaultValue] [nvarchar] (1000) NOT NULL,
[Source] [nvarchar] (max) NOT NULL,
[TableName] [varchar] (100) NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_OptionProperty_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFOptionPropertyStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFOptionPropertyEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
[Description] [nvarchar] (1000) NOT NULL CONSTRAINT [DF__OptionPro__Descr__61824303] DEFAULT (''),
[ColumnName] [varchar] (100) NULL,
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_OptionProperty] PRIMARY KEY CLUSTERED ([OptionPropertyId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[OptionPropertyHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[OptionProperty]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkOptionPropertyOptionIdOptionProperty]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[OptionProperty]', 'U'))
ALTER TABLE [dbo].[OptionProperty] ADD CONSTRAINT [UkOptionPropertyOptionIdOptionProperty] UNIQUE NONCLUSTERED ([OptionId], [OptionProperty])
GO
PRINT N'Creating [dbo].[Option]'
GO
IF OBJECT_ID(N'[dbo].[OptionHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[OptionHistoryLog]
(
[OptionId] [int] NOT NULL,
[Option] [varchar] (100) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL,
[RelatesTo] [varchar] (1000) NULL
)
GO
PRINT N'Creating index [ix_OptionHistoryLog] on [dbo].[OptionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_OptionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[OptionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_OptionHistoryLog] ON [dbo].[OptionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Option]', 'U') IS NULL
CREATE TABLE [dbo].[Option]
(
[OptionId] [int] NOT NULL IDENTITY(1, 1),
[Option] [varchar] (100) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Option_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFOptionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFOptionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
[RelatesTo] [varchar] (1000) NULL,
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Option] PRIMARY KEY CLUSTERED ([OptionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[OptionHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[Option]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkOptionOption]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[Option]', 'U'))
ALTER TABLE [dbo].[Option] ADD CONSTRAINT [UkOptionOption] UNIQUE NONCLUSTERED ([Option])
GO
PRINT N'Creating [dbo].[Organization]'
GO
IF OBJECT_ID(N'[dbo].[OrganizationHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[OrganizationHistoryLog]
(
[OrganizationId] [int] NOT NULL,
[OfficeId] [int] NOT NULL,
[Organization] [nvarchar] (100) NOT NULL,
[Department] [nvarchar] (100) NOT NULL,
[ParentOrganizationId] [int] NULL,
[RootOrganizationId] [int] NULL,
[BackOfficeId] [int] NULL,
[FundingOrganizationId] [int] NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[ReferenceId] [varchar] (50) NULL,
[ReferenceNote] [varchar] (100) NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_OrganizationHistoryLog] on [dbo].[OrganizationHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_OrganizationHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[OrganizationHistoryLog]'))
CREATE CLUSTERED INDEX [ix_OrganizationHistoryLog] ON [dbo].[OrganizationHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Organization]', 'U') IS NULL
CREATE TABLE [dbo].[Organization]
(
[OrganizationId] [int] NOT NULL IDENTITY(1, 1),
[OfficeId] [int] NOT NULL,
[Organization] [nvarchar] (100) NOT NULL,
[Department] [nvarchar] (100) NOT NULL,
[ParentOrganizationId] [int] NULL,
[RootOrganizationId] [int] NULL,
[BackOfficeId] [int] NULL,
[FundingOrganizationId] [int] NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Organization_InsertDate] DEFAULT (getdate()),
[ReferenceId] [varchar] (50) NULL,
[ReferenceNote] [varchar] (100) NULL,
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFOrganizationStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFOrganizationEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED ([OrganizationId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[OrganizationHistoryLog])
)
GO
PRINT N'Creating index [IXOrganizationOfficeId] on [dbo].[Organization]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IXOrganizationOfficeId' AND object_id = OBJECT_ID(N'[dbo].[Organization]'))
CREATE NONCLUSTERED INDEX [IXOrganizationOfficeId] ON [dbo].[Organization] ([OfficeId])
GO
PRINT N'Creating [dbo].[OrganizationOption]'
GO
IF OBJECT_ID(N'[dbo].[OrganizationOptionHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[OrganizationOptionHistoryLog]
(
[OrganizationOptionId] [int] NOT NULL,
[OrganizationId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_OrganizationOptionHistoryLog] on [dbo].[OrganizationOptionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_OrganizationOptionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[OrganizationOptionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_OrganizationOptionHistoryLog] ON [dbo].[OrganizationOptionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[OrganizationOption]', 'U') IS NULL
CREATE TABLE [dbo].[OrganizationOption]
(
[OrganizationOptionId] [int] NOT NULL IDENTITY(1, 1),
[OrganizationId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_OrganizationOption_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFOrganizationOptionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFOrganizationOptionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_OrganizationOption] PRIMARY KEY CLUSTERED ([OrganizationOptionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[OrganizationOptionHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[OrganizationOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkOrganizationOptionOrganizationIdOptionPropertyId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[OrganizationOption]', 'U'))
ALTER TABLE [dbo].[OrganizationOption] ADD CONSTRAINT [UkOrganizationOptionOrganizationIdOptionPropertyId] UNIQUE NONCLUSTERED ([OrganizationId], [OptionPropertyId])
GO
PRINT N'Creating [dbo].[PersonOption]'
GO
IF OBJECT_ID(N'[dbo].[PersonOptionHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[PersonOptionHistoryLog]
(
[PersonOptionId] [int] NOT NULL,
[PersonId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_PersonOptionHistoryLog] on [dbo].[PersonOptionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_PersonOptionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[PersonOptionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_PersonOptionHistoryLog] ON [dbo].[PersonOptionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[PersonOption]', 'U') IS NULL
CREATE TABLE [dbo].[PersonOption]
(
[PersonOptionId] [int] NOT NULL IDENTITY(1, 1),
[PersonId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_PersonOption_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFPersonOptionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFPersonOptionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_PersonOption] PRIMARY KEY CLUSTERED ([PersonOptionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[PersonOptionHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[PersonOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkPersonOptionPersonIdOptionPropertyId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[PersonOption]', 'U'))
ALTER TABLE [dbo].[PersonOption] ADD CONSTRAINT [UkPersonOptionPersonIdOptionPropertyId] UNIQUE NONCLUSTERED ([PersonId], [OptionPropertyId])
GO
PRINT N'Creating [dbo].[SystemOption]'
GO
IF OBJECT_ID(N'[dbo].[SystemOptionHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[SystemOptionHistoryLog]
(
[SystemOptionId] [int] NOT NULL,
[SystemId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_SystemOptionHistoryLog] on [dbo].[SystemOptionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_SystemOptionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[SystemOptionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_SystemOptionHistoryLog] ON [dbo].[SystemOptionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[SystemOption]', 'U') IS NULL
CREATE TABLE [dbo].[SystemOption]
(
[SystemOptionId] [int] NOT NULL IDENTITY(1, 1),
[SystemId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_SystemOption_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFSystemOptionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFSystemOptionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_SystemOption] PRIMARY KEY CLUSTERED ([SystemOptionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[SystemOptionHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[SystemOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkSystemOptionSystemIdOptionPropertyId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[SystemOption]', 'U'))
ALTER TABLE [dbo].[SystemOption] ADD CONSTRAINT [UkSystemOptionSystemIdOptionPropertyId] UNIQUE NONCLUSTERED ([SystemId], [OptionPropertyId])
GO
PRINT N'Creating [dbo].[System]'
GO
IF OBJECT_ID(N'[dbo].[SystemHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[SystemHistoryLog]
(
[SystemId] [int] NOT NULL,
[System] [varchar] (15) NOT NULL,
[Version] [varchar] (25) NOT NULL,
[VersionNumber] [int] NOT NULL,
[Mode] [char] (1) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_SystemHistoryLog] on [dbo].[SystemHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_SystemHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[SystemHistoryLog]'))
CREATE CLUSTERED INDEX [ix_SystemHistoryLog] ON [dbo].[SystemHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[System]', 'U') IS NULL
CREATE TABLE [dbo].[System]
(
[SystemId] [int] NOT NULL,
[System] [varchar] (15) NOT NULL,
[Version] [varchar] (25) NOT NULL,
[VersionNumber] [int] NOT NULL,
[Mode] [char] (1) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_System_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFSystemStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFSystemEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_System] PRIMARY KEY CLUSTERED ([SystemId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[SystemHistoryLog])
)
GO
PRINT N'Creating [dbo].[Tenant]'
GO
IF OBJECT_ID(N'[dbo].[TenantHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[TenantHistoryLog]
(
[TenantId] [int] NOT NULL,
[SystemId] [int] NOT NULL,
[Tenant] [nvarchar] (100) NOT NULL,
[TenantTypeListItemId] [int] NULL,
[OrganizationId] [int] NOT NULL,
[NodeId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_TenantHistoryLog] on [dbo].[TenantHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_TenantHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[TenantHistoryLog]'))
CREATE CLUSTERED INDEX [ix_TenantHistoryLog] ON [dbo].[TenantHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Tenant]', 'U') IS NULL
CREATE TABLE [dbo].[Tenant]
(
[TenantId] [int] NOT NULL IDENTITY(1, 1),
[SystemId] [int] NOT NULL,
[Tenant] [nvarchar] (100) NOT NULL,
[TenantTypeListItemId] [int] NULL,
[OrganizationId] [int] NOT NULL,
[NodeId] [int] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Tenant_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFTenantStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFTenantEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Tenant] PRIMARY KEY CLUSTERED ([TenantId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[TenantHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[Tenant]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkTenantTenant]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[Tenant]', 'U'))
ALTER TABLE [dbo].[Tenant] ADD CONSTRAINT [UkTenantTenant] UNIQUE NONCLUSTERED ([Tenant])
GO
PRINT N'Creating [dbo].[TenantOption]'
GO
IF OBJECT_ID(N'[dbo].[TenantOptionHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[TenantOptionHistoryLog]
(
[TenantOptionId] [int] NOT NULL,
[TenantId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_TenantOptionHistoryLog] on [dbo].[TenantOptionHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_TenantOptionHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[TenantOptionHistoryLog]'))
CREATE CLUSTERED INDEX [ix_TenantOptionHistoryLog] ON [dbo].[TenantOptionHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[TenantOption]', 'U') IS NULL
CREATE TABLE [dbo].[TenantOption]
(
[TenantOptionId] [int] NOT NULL IDENTITY(1, 1),
[TenantId] [int] NOT NULL,
[OptionPropertyId] [int] NOT NULL,
[OptionValue] [nvarchar] (1000) NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_TenantOption_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFTenantOptionStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFTenantOptionEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_TenantOption] PRIMARY KEY CLUSTERED ([TenantOptionId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[TenantOptionHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[TenantOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkTenantOptionTenantIdOptionPropertyId]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[TenantOption]', 'U'))
ALTER TABLE [dbo].[TenantOption] ADD CONSTRAINT [UkTenantOptionTenantIdOptionPropertyId] UNIQUE NONCLUSTERED ([TenantId], [OptionPropertyId])
GO
PRINT N'Creating [dbo].[WHUserLog]'
GO
IF OBJECT_ID(N'[dbo].[WHUserLog]', 'SN') IS NULL
CREATE SYNONYM [dbo].[WHUserLog] FOR [ZenopleMasterNextWH].[dbo].[UserLog]
GO
PRINT N'Creating [dbo].[Culture]'
GO
IF OBJECT_ID(N'[dbo].[CultureHistoryLog]', 'U') IS NULL
CREATE TABLE [dbo].[CultureHistoryLog]
(
[CultureId] [int] NOT NULL,
[CultureCode] [varchar] (5) NOT NULL,
[Language] [nvarchar] (25) NOT NULL,
[SortOrder] [tinyint] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL,
[StartPeriod] [datetime2] NOT NULL,
[EndPeriod] [datetime2] NOT NULL
)
GO
PRINT N'Creating index [ix_CultureHistoryLog] on [dbo].[CultureHistoryLog]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_CultureHistoryLog' AND object_id = OBJECT_ID(N'[dbo].[CultureHistoryLog]'))
CREATE CLUSTERED INDEX [ix_CultureHistoryLog] ON [dbo].[CultureHistoryLog] ([EndPeriod], [StartPeriod])
GO
IF OBJECT_ID(N'[dbo].[Culture]', 'U') IS NULL
CREATE TABLE [dbo].[Culture]
(
[CultureId] [int] NOT NULL IDENTITY(1, 1),
[CultureCode] [varchar] (5) NOT NULL,
[Language] [nvarchar] (25) NOT NULL,
[SortOrder] [tinyint] NOT NULL,
[UserPersonId] [int] NOT NULL,
[InsertDate] [smalldatetime] NOT NULL CONSTRAINT [DF_Culture_InsertDate] DEFAULT (getdate()),
[StartPeriod] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL CONSTRAINT [DFCultureStartPeriod] DEFAULT (sysutcdatetime()),
[EndPeriod] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL CONSTRAINT [DFCultureEndPeriod] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999',(0))),
PERIOD FOR SYSTEM_TIME (StartPeriod, EndPeriod),
CONSTRAINT [PK_Culture] PRIMARY KEY CLUSTERED ([CultureId])
)
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[CultureHistoryLog])
)
GO
PRINT N'Adding constraints to [dbo].[Culture]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UkCultureCultureCode]', 'UQ') AND parent_object_id = OBJECT_ID(N'[dbo].[Culture]', 'U'))
ALTER TABLE [dbo].[Culture] ADD CONSTRAINT [UkCultureCultureCode] UNIQUE NONCLUSTERED ([CultureCode])
GO
PRINT N'Adding constraints to [dbo].[System]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_System_PK]', 'C') AND parent_object_id = OBJECT_ID(N'[dbo].[System]', 'U'))
ALTER TABLE [dbo].[System] ADD CONSTRAINT [CK_System_PK] CHECK (([SystemId]=(1)))
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_System_Mode]', 'C') AND parent_object_id = OBJECT_ID(N'[dbo].[System]', 'U'))
ALTER TABLE [dbo].[System] ADD CONSTRAINT [CK_System_Mode] CHECK (([Mode]='T' OR [Mode]='L'))
GO
PRINT N'Adding foreign keys to [dbo].[ApplicationNavigationAction]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationNavigationAction_Application]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationNavigationAction]', 'U'))
ALTER TABLE [dbo].[ApplicationNavigationAction] ADD CONSTRAINT [FK_ApplicationNavigationAction_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationNavigationAction_NavigationAction]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationNavigationAction]', 'U'))
ALTER TABLE [dbo].[ApplicationNavigationAction] ADD CONSTRAINT [FK_ApplicationNavigationAction_NavigationAction] FOREIGN KEY ([NavigationActionId]) REFERENCES [dbo].[NavigationAction] ([NavigationActionId])
GO
PRINT N'Adding foreign keys to [dbo].[ApplicationNavigation]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationNavigation_Application]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationNavigation]', 'U'))
ALTER TABLE [dbo].[ApplicationNavigation] ADD CONSTRAINT [FK_ApplicationNavigation_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationNavigation_Navigation]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationNavigation]', 'U'))
ALTER TABLE [dbo].[ApplicationNavigation] ADD CONSTRAINT [FK_ApplicationNavigation_Navigation] FOREIGN KEY ([NavigationId]) REFERENCES [dbo].[Navigation] ([NavigationId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationNavigation_Application2]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationNavigation]', 'U'))
ALTER TABLE [dbo].[ApplicationNavigation] ADD CONSTRAINT [FK_ApplicationNavigation_Application2] FOREIGN KEY ([ParentApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
GO
PRINT N'Adding foreign keys to [dbo].[ApplicationRoleNavigationAction]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationRoleNavigationAction_ApplicationRole]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRoleNavigationAction]', 'U'))
ALTER TABLE [dbo].[ApplicationRoleNavigationAction] ADD CONSTRAINT [FK_ApplicationRoleNavigationAction_ApplicationRole] FOREIGN KEY ([ApplicationRoleId]) REFERENCES [dbo].[ApplicationRole] ([ApplicationRoleId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationRoleNavigationAction_NavigationAction]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRoleNavigationAction]', 'U'))
ALTER TABLE [dbo].[ApplicationRoleNavigationAction] ADD CONSTRAINT [FK_ApplicationRoleNavigationAction_NavigationAction] FOREIGN KEY ([NavigationActionId]) REFERENCES [dbo].[NavigationAction] ([NavigationActionId])
GO
PRINT N'Adding foreign keys to [dbo].[ApplicationRoleNavigation]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationRoleNavigation_ApplicationRole]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRoleNavigation]', 'U'))
ALTER TABLE [dbo].[ApplicationRoleNavigation] ADD CONSTRAINT [FK_ApplicationRoleNavigation_ApplicationRole] FOREIGN KEY ([ApplicationRoleId]) REFERENCES [dbo].[ApplicationRole] ([ApplicationRoleId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationRoleNavigation_Navigation]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRoleNavigation]', 'U'))
ALTER TABLE [dbo].[ApplicationRoleNavigation] ADD CONSTRAINT [FK_ApplicationRoleNavigation_Navigation] FOREIGN KEY ([NavigationId]) REFERENCES [dbo].[Navigation] ([NavigationId])
GO
PRINT N'Adding foreign keys to [dbo].[ApplicationRole]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationRole_Application]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRole]', 'U'))
ALTER TABLE [dbo].[ApplicationRole] ADD CONSTRAINT [FK_ApplicationRole_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[Application] ([ApplicationId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationRole_Role]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRole]', 'U'))
ALTER TABLE [dbo].[ApplicationRole] ADD CONSTRAINT [FK_ApplicationRole_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([RoleId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ApplicationRole_Navigation]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ApplicationRole]', 'U'))
ALTER TABLE [dbo].[ApplicationRole] ADD CONSTRAINT [FK_ApplicationRole_Navigation] FOREIGN KEY ([NavigationId]) REFERENCES [dbo].[Navigation] ([NavigationId])
GO
PRINT N'Adding foreign keys to [dbo].[Application]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Application_Resource]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Application]', 'U'))
ALTER TABLE [dbo].[Application] ADD CONSTRAINT [FK_Application_Resource] FOREIGN KEY ([ResourceId]) REFERENCES [dbo].[Resource] ([ResourceId])
GO
PRINT N'Adding foreign keys to [dbo].[ListItem]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ListItem_ListItemCategory]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[ListItem]', 'U'))
ALTER TABLE [dbo].[ListItem] ADD CONSTRAINT [FK_ListItem_ListItemCategory] FOREIGN KEY ([ListItemCategoryId]) REFERENCES [dbo].[ListItemCategory] ([ListItemCategoryId])
GO
PRINT N'Adding foreign keys to [dbo].[NavigationAction]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_NavigationAction_Navigation]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[NavigationAction]', 'U'))
ALTER TABLE [dbo].[NavigationAction] ADD CONSTRAINT [FK_NavigationAction_Navigation] FOREIGN KEY ([NavigationId]) REFERENCES [dbo].[Navigation] ([NavigationId])
GO
PRINT N'Adding foreign keys to [dbo].[NavigationNode]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_NavigationNode_Navigation]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[NavigationNode]', 'U'))
ALTER TABLE [dbo].[NavigationNode] ADD CONSTRAINT [FK_NavigationNode_Navigation] FOREIGN KEY ([NavigationId]) REFERENCES [dbo].[Navigation] ([NavigationId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_NavigationNode_Node]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[NavigationNode]', 'U'))
ALTER TABLE [dbo].[NavigationNode] ADD CONSTRAINT [FK_NavigationNode_Node] FOREIGN KEY ([NodeId]) REFERENCES [dbo].[Node] ([NodeId])
GO
PRINT N'Adding foreign keys to [dbo].[Navigation]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Navigation_Navigation]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Navigation]', 'U'))
ALTER TABLE [dbo].[Navigation] ADD CONSTRAINT [FK_Navigation_Navigation] FOREIGN KEY ([RootNavigationId]) REFERENCES [dbo].[Navigation] ([NavigationId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Navigation_Navigation1]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Navigation]', 'U'))
ALTER TABLE [dbo].[Navigation] ADD CONSTRAINT [FK_Navigation_Navigation1] FOREIGN KEY ([ParentNavigationId]) REFERENCES [dbo].[Navigation] ([NavigationId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Navigation_Resource]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Navigation]', 'U'))
ALTER TABLE [dbo].[Navigation] ADD CONSTRAINT [FK_Navigation_Resource] FOREIGN KEY ([ResourceId]) REFERENCES [dbo].[Resource] ([ResourceId])
GO
PRINT N'Adding foreign keys to [dbo].[Node]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Node_NodeType]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Node]', 'U'))
ALTER TABLE [dbo].[Node] ADD CONSTRAINT [FK_Node_NodeType] FOREIGN KEY ([NodeTypeId]) REFERENCES [dbo].[NodeType] ([NodeTypeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Node_Node]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Node]', 'U'))
ALTER TABLE [dbo].[Node] ADD CONSTRAINT [FK_Node_Node] FOREIGN KEY ([ParentNodeId]) REFERENCES [dbo].[Node] ([NodeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Node_Node1]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Node]', 'U'))
ALTER TABLE [dbo].[Node] ADD CONSTRAINT [FK_Node_Node1] FOREIGN KEY ([RootNodeId]) REFERENCES [dbo].[Node] ([NodeId])
GO
PRINT N'Adding foreign keys to [dbo].[NodeType]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_NodeType_NodeType]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[NodeType]', 'U'))
ALTER TABLE [dbo].[NodeType] ADD CONSTRAINT [FK_NodeType_NodeType] FOREIGN KEY ([RootNodeTypeId]) REFERENCES [dbo].[NodeType] ([NodeTypeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_NodeType_NodeType1]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[NodeType]', 'U'))
ALTER TABLE [dbo].[NodeType] ADD CONSTRAINT [FK_NodeType_NodeType1] FOREIGN KEY ([ParentNodeTypeId]) REFERENCES [dbo].[NodeType] ([NodeTypeId])
GO
PRINT N'Adding foreign keys to [dbo].[Office]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Office_Node]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Office]', 'U'))
ALTER TABLE [dbo].[Office] ADD CONSTRAINT [FK_Office_Node] FOREIGN KEY ([NodeId]) REFERENCES [dbo].[Node] ([NodeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Office_Office]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Office]', 'U'))
ALTER TABLE [dbo].[Office] ADD CONSTRAINT [FK_Office_Office] FOREIGN KEY ([RootOfficeId]) REFERENCES [dbo].[Office] ([OfficeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Office_Office1]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Office]', 'U'))
ALTER TABLE [dbo].[Office] ADD CONSTRAINT [FK_Office_Office1] FOREIGN KEY ([ParentOfficeId]) REFERENCES [dbo].[Office] ([OfficeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Office_Office2]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Office]', 'U'))
ALTER TABLE [dbo].[Office] ADD CONSTRAINT [FK_Office_Office2] FOREIGN KEY ([BackOfficeId]) REFERENCES [dbo].[Office] ([OfficeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Office_TenantOrganization]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Office]', 'U'))
ALTER TABLE [dbo].[Office] ADD CONSTRAINT [FK_Office_TenantOrganization] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[TenantOrganization] ([OrganizationId])
GO
PRINT N'Adding foreign keys to [dbo].[Tenant]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Tenant_Node]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Tenant]', 'U'))
ALTER TABLE [dbo].[Tenant] ADD CONSTRAINT [FK_Tenant_Node] FOREIGN KEY ([NodeId]) REFERENCES [dbo].[Node] ([NodeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Tenant_System]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Tenant]', 'U'))
ALTER TABLE [dbo].[Tenant] ADD CONSTRAINT [FK_Tenant_System] FOREIGN KEY ([SystemId]) REFERENCES [dbo].[System] ([SystemId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Tenant_TenantOrganization]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Tenant]', 'U'))
ALTER TABLE [dbo].[Tenant] ADD CONSTRAINT [FK_Tenant_TenantOrganization] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[TenantOrganization] ([OrganizationId])
GO
PRINT N'Adding foreign keys to [dbo].[TenantOrganization]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TenantOrganization_Node]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[TenantOrganization]', 'U'))
ALTER TABLE [dbo].[TenantOrganization] ADD CONSTRAINT [FK_TenantOrganization_Node] FOREIGN KEY ([NodeId]) REFERENCES [dbo].[Node] ([NodeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TenantOrganization_Office]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[TenantOrganization]', 'U'))
ALTER TABLE [dbo].[TenantOrganization] ADD CONSTRAINT [FK_TenantOrganization_Office] FOREIGN KEY ([OfficeId]) REFERENCES [dbo].[Office] ([OfficeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TenantOrganization_Organization]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[TenantOrganization]', 'U'))
ALTER TABLE [dbo].[TenantOrganization] ADD CONSTRAINT [FK_TenantOrganization_Organization] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization] ([OrganizationId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TenantOrganization_Tenant]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[TenantOrganization]', 'U'))
ALTER TABLE [dbo].[TenantOrganization] ADD CONSTRAINT [FK_TenantOrganization_Tenant] FOREIGN KEY ([TenantId]) REFERENCES [dbo].[Tenant] ([TenantId])
GO
PRINT N'Adding foreign keys to [dbo].[OfficeOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OfficeOption_Office]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[OfficeOption]', 'U'))
ALTER TABLE [dbo].[OfficeOption] ADD CONSTRAINT [FK_OfficeOption_Office] FOREIGN KEY ([OfficeId]) REFERENCES [dbo].[Office] ([OfficeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OfficeOption_OptionProperty]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[OfficeOption]', 'U'))
ALTER TABLE [dbo].[OfficeOption] ADD CONSTRAINT [FK_OfficeOption_OptionProperty] FOREIGN KEY ([OptionPropertyId]) REFERENCES [dbo].[OptionProperty] ([OptionPropertyId])
GO
PRINT N'Adding foreign keys to [dbo].[Organization]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Organization_Office]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Organization]', 'U'))
ALTER TABLE [dbo].[Organization] ADD CONSTRAINT [FK_Organization_Office] FOREIGN KEY ([OfficeId]) REFERENCES [dbo].[Office] ([OfficeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Organization_Office1]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Organization]', 'U'))
ALTER TABLE [dbo].[Organization] ADD CONSTRAINT [FK_Organization_Office1] FOREIGN KEY ([BackOfficeId]) REFERENCES [dbo].[Office] ([OfficeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Organization_Organization]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Organization]', 'U'))
ALTER TABLE [dbo].[Organization] ADD CONSTRAINT [FK_Organization_Organization] FOREIGN KEY ([FundingOrganizationId]) REFERENCES [dbo].[Organization] ([OrganizationId])
GO
PRINT N'Adding foreign keys to [dbo].[OrganizationOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrganizationOption_OptionProperty]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[OrganizationOption]', 'U'))
ALTER TABLE [dbo].[OrganizationOption] ADD CONSTRAINT [FK_OrganizationOption_OptionProperty] FOREIGN KEY ([OptionPropertyId]) REFERENCES [dbo].[OptionProperty] ([OptionPropertyId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OrganizationOption_Organization]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[OrganizationOption]', 'U'))
ALTER TABLE [dbo].[OrganizationOption] ADD CONSTRAINT [FK_OrganizationOption_Organization] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization] ([OrganizationId])
GO
PRINT N'Adding foreign keys to [dbo].[PersonOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PersonOption_OptionProperty]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[PersonOption]', 'U'))
ALTER TABLE [dbo].[PersonOption] ADD CONSTRAINT [FK_PersonOption_OptionProperty] FOREIGN KEY ([OptionPropertyId]) REFERENCES [dbo].[OptionProperty] ([OptionPropertyId])
GO
PRINT N'Adding foreign keys to [dbo].[SystemOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SystemOption_OptionProperty]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[SystemOption]', 'U'))
ALTER TABLE [dbo].[SystemOption] ADD CONSTRAINT [FK_SystemOption_OptionProperty] FOREIGN KEY ([OptionPropertyId]) REFERENCES [dbo].[OptionProperty] ([OptionPropertyId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SystemOption_System]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[SystemOption]', 'U'))
ALTER TABLE [dbo].[SystemOption] ADD CONSTRAINT [FK_SystemOption_System] FOREIGN KEY ([SystemId]) REFERENCES [dbo].[System] ([SystemId])
GO
PRINT N'Adding foreign keys to [dbo].[TenantOption]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TenantOption_OptionProperty]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[TenantOption]', 'U'))
ALTER TABLE [dbo].[TenantOption] ADD CONSTRAINT [FK_TenantOption_OptionProperty] FOREIGN KEY ([OptionPropertyId]) REFERENCES [dbo].[OptionProperty] ([OptionPropertyId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TenantOption_Tenant]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[TenantOption]', 'U'))
ALTER TABLE [dbo].[TenantOption] ADD CONSTRAINT [FK_TenantOption_Tenant] FOREIGN KEY ([TenantId]) REFERENCES [dbo].[Tenant] ([TenantId])
GO
PRINT N'Adding foreign keys to [dbo].[OptionProperty]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OptionProperty_Option]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[OptionProperty]', 'U'))
ALTER TABLE [dbo].[OptionProperty] ADD CONSTRAINT [FK_OptionProperty_Option] FOREIGN KEY ([OptionId]) REFERENCES [dbo].[Option] ([OptionId])
GO
PRINT N'Adding foreign keys to [dbo].[Role]'
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Role_Resource]','F') AND parent_object_id = OBJECT_ID(N'[dbo].[Role]', 'U'))
ALTER TABLE [dbo].[Role] ADD CONSTRAINT [FK_Role_Resource] FOREIGN KEY ([ResourceId]) REFERENCES [dbo].[Resource] ([ResourceId])
GO
PRINT N'Creating extended properties'
GO
IF NOT EXISTS (SELECT 1 FROM fn_listextendedproperty(N'Description', 'SCHEMA', N'dbo', 'TABLE', N'Office', NULL, NULL))
EXEC sp_addextendedproperty N'Description', N'samar
07/11/2017

This table will have the list of office (logical or phycial, cost centers, site location) for TenantOrganization', 'SCHEMA', N'dbo', 'TABLE', N'Office', NULL, NULL
GO
IF NOT EXISTS (SELECT 1 FROM fn_listextendedproperty(N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N'Option', NULL, NULL))
EXEC sp_addextendedproperty N'MS_Description', N'Purpose of Adding RelatesTo column is to Differentiate the Option that are used while setting up Email profile from ATM app', 'SCHEMA', N'dbo', 'TABLE', N'Option', NULL, NULL
GO
IF NOT EXISTS (SELECT 1 FROM fn_listextendedproperty(N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N'Organization', NULL, NULL))
EXEC sp_addextendedproperty N'MS_Description', N'OfficeId for Tenant,Organization and TenantOrganization is its main office
OfficeId for Lead,Target,NewCustomer,Customer and Agency is its handling office.
OfficeId is by default handling office.If the organization is only TenantOrganization then it is the default office.
', 'SCHEMA', N'dbo', 'TABLE', N'Organization', NULL, NULL
GO
IF NOT EXISTS (SELECT 1 FROM fn_listextendedproperty(N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N'TenantOrganization', NULL, NULL))
EXEC sp_addextendedproperty N'MS_Description', N'TenantOrganization are the actual organization that uses the system. Staffing Companies, Corporate HR, Recruiter Agency, PEO, ASO, HRO will be in this table.
OfficeId is default office of the TenantOrganization', 'SCHEMA', N'dbo', 'TABLE', N'TenantOrganization', NULL, NULL
GO
