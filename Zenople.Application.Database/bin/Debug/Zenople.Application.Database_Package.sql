﻿/*
    Generated date:     2022-04-29T15:24:18Z
    Generated on:       AQ-DELL2203PC98
    Package version:    
    Migration version:  (n/a)
    Baseline version:   (n/a)
    SQL Change Automation version:  4.3.21259.27287

    IMPORTANT! "SQLCMD Mode" must be activated prior to execution (under the Query menu in SSMS).

    BEFORE EXECUTING THIS SCRIPT, WE STRONGLY RECOMMEND YOU TAKE A BACKUP OF YOUR DATABASE.

    This SQLCMD script is designed to be executed through MSBuild (via the .sqlproj Deploy target) however
    it can also be run manually using SQL Management Studio.

    It was generated by the SQL Change Automation build task and contains logic to deploy the database, ensuring that
    each of the incremental migrations is executed a single time only in alphabetical (filename)
    order. If any errors occur within those scripts, the deployment will be aborted and the transaction
    rolled-back.

    NOTE: Automatic transaction management is provided for incremental migrations, so you don't need to
          add any special BEGIN TRAN/COMMIT/ROLLBACK logic in those script files.
          However if you require transaction handling in your Pre/Post-Deployment scripts, you will
          need to add this logic to the source .sql files yourself.
*/

----====================================================================================================================
---- SQLCMD Variables
---- This script is designed to be called by SQLCMD.EXE with variables specified on the command line.
---- However you can also run it in SQL Management Studio by uncommenting this section (CTRL+K, CTRL+U).
--:setvar DatabaseName ""
--:setvar ReleaseVersion ""
--:setvar ForceDeployWithoutBaseline "False"
--:setvar DefaultFilePrefix ""
--:setvar DefaultDataPath ""
--:setvar DefaultLogPath ""
--:setvar DefaultBackupPath ""
--:setvar DeployPath ""
----====================================================================================================================

:on error exit -- Instructs SQLCMD to abort execution as soon as an erroneous batch is encountered

:setvar PackageVersion ""
:setvar IsShadowDeployment 0

GO
:setvar IsSqlCmdEnabled "True"
GO

IF N'$(DatabaseName)' = N'$' + N'(DatabaseName)' OR
   N'$(ReleaseVersion)' = N'$' + N'(ReleaseVersion)' OR
   N'$(ForceDeployWithoutBaseline)' = N'$' + N'(ForceDeployWithoutBaseline)'
      RAISERROR('(This will not throw). Please make sure that all SQLCMD variables are defined before running this script.', 0, 0);
GO

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON; -- Abort the current batch immediately if a statement raises a run-time error and rollback any open transaction(s)

IF N'$(IsSqlCmdEnabled)' <> N'True' -- Is SQLCMD mode not enabled within the execution context (eg. SSMS)
    BEGIN
        IF IS_SRVROLEMEMBER(N'sysadmin') = 1
            BEGIN -- User is sysadmin; abort execution by disconnect the script from the database server
                RAISERROR(N'This script must be run in SQLCMD Mode (under the Query menu in SSMS). Aborting connection to suppress subsequent errors.', 20, 127, N'UNKNOWN') WITH LOG;
            END
        ELSE
            BEGIN -- User is not sysadmin; abort execution by switching off statement execution (script will continue to the end without performing any actual deployment work)
                RAISERROR(N'This script must be run in SQLCMD Mode (under the Query menu in SSMS). Script execution has been halted.', 16, 127, N'UNKNOWN') WITH NOWAIT;
            END
    END
GO
IF @@ERROR != 0
    BEGIN
        SET NOEXEC ON; -- SQLCMD is NOT enabled so prevent any further statements from executing
    END
GO
-- Beyond this point, no further explicit error handling is required because it can be assumed that SQLCMD mode is enabled

IF SERVERPROPERTY('EngineEdition') = 5 AND DB_NAME() != N'$(DatabaseName)'
  RAISERROR(N'Azure SQL Database does not support switching between databases. Connect to [$(DatabaseName)] and then re-run the script.', 16, 127);








------------------------------------------------------------------------------------------------------------------------
------------------------------------------       PRE-DEPLOYMENT SCRIPTS       ------------------------------------------
------------------------------------------------------------------------------------------------------------------------

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;

PRINT '----- executing pre-deployment script "Pre-Deployment\01_Initialize_Deployment.sql" -----';
GO

---------------------- BEGIN PRE-DEPLOYMENT SCRIPT: "Pre-Deployment\01_Initialize_Deployment.sql" ------------------------
/*
Pre-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be prepended to the build script.
 Use SQLCMD syntax to include a file in the pre-deployment script.
 Example:      :r .\myfile.sql
 Use SQLCMD syntax to reference a variable in the post-deployment script.
 Example:      :setvar TableName MyTable
               SELECT * FROM [$(TableName)]
--------------------------------------------------------------------------------------
*/

GO
----------------------- END PRE-DEPLOYMENT SCRIPT: "Pre-Deployment\01_Initialize_Deployment.sql" -------------------------

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;









------------------------------------------------------------------------------------------------------------------------
------------------------------------------       INCREMENTAL MIGRATIONS       ------------------------------------------
------------------------------------------------------------------------------------------------------------------------

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;

GO
PRINT '# Beginning transaction';

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SET XACT_ABORT ON;

BEGIN TRANSACTION;

GO
IF DB_NAME() != '$(DatabaseName)'
  USE [$(DatabaseName)];

GO
PRINT '# Setting up migration log table';
IF (NOT EXISTS (SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[__MigrationLog]') AND [type] = 'U'))
  BEGIN
    IF OBJECT_ID(N'[dbo].[__MigrationLogCurrent]', 'V') IS NOT NULL
      DROP VIEW [dbo].[__MigrationLogCurrent];
    PRINT '# Creating a new migration log table';
    CREATE TABLE [dbo].[__MigrationLog] (
      [migration_id] UNIQUEIDENTIFIER NOT NULL,
      [script_checksum] NVARCHAR (64) NOT NULL,
      [script_filename] NVARCHAR (255) NOT NULL,
      [complete_dt] DATETIME2 NOT NULL,
      [applied_by] NVARCHAR (100) NOT NULL,
      [deployed] TINYINT CONSTRAINT [DF___MigrationLog_deployed] DEFAULT (1) NOT NULL,
      [version] VARCHAR (255) NULL,
      [package_version] VARCHAR (255) NULL,
      [release_version] VARCHAR (255) NULL,
      [sequence_no] INT IDENTITY (1, 1) NOT NULL CONSTRAINT [PK___MigrationLog] PRIMARY KEY CLUSTERED ([migration_id], [complete_dt], [script_checksum]));
    CREATE NONCLUSTERED INDEX [IX___MigrationLog_CompleteDt]
      ON [dbo].[__MigrationLog]([complete_dt]);
    CREATE NONCLUSTERED INDEX [IX___MigrationLog_Version]
      ON [dbo].[__MigrationLog]([version]);
    CREATE UNIQUE NONCLUSTERED INDEX [UX___MigrationLog_SequenceNo]
      ON [dbo].[__MigrationLog]([sequence_no]);
    EXECUTE ('
	CREATE VIEW [dbo].[__MigrationLogCurrent]
			AS
			WITH currentMigration AS
			(
			  SELECT
				 migration_id, script_checksum, script_filename, complete_dt, applied_by, deployed, ROW_NUMBER() OVER(PARTITION BY migration_id ORDER BY sequence_no DESC) AS RowNumber
			  FROM [dbo].[__MigrationLog]
			)
			SELECT  migration_id, script_checksum, script_filename, complete_dt, applied_by, deployed
			FROM currentMigration
			WHERE RowNumber = 1
	');
    IF OBJECT_ID(N'sp_addextendedproperty', 'P') IS NOT NULL
      BEGIN
        PRINT N'Creating extended properties';
        EXECUTE sp_addextendedproperty N'MS_Description', N'This table is required by SQL Change Automation projects to keep track of which migrations have been executed during deployment. Please do not alter or remove this table from the database.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', NULL, NULL;
        EXECUTE sp_addextendedproperty N'MS_Description', N'The executing user at the time of deployment (populated using the SYSTEM_USER function).', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'applied_by';
        EXECUTE sp_addextendedproperty N'MS_Description', N'The date/time that the migration finished executing. This value is populated using the SYSDATETIME function.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'complete_dt';
        EXECUTE sp_addextendedproperty N'MS_Description', N'This column contains a number of potential states:

0 - Marked As Deployed: The migration was not executed.
1- Deployed: The migration was executed successfully.
2- Imported: The migration was generated by importing from this DB.

"Marked As Deployed" and "Imported" are similar in that the migration was not executed on this database; it was was only marked as such to prevent it from executing during subsequent deployments.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'deployed';
        EXECUTE sp_addextendedproperty N'MS_Description', N'The unique identifier of a migration script file. This value is stored within the <Migration /> Xml fragment within the header of the file itself.

Note that it is possible for this value to repeat in the [__MigrationLog] table. In the case of programmable object scripts, a record will be inserted with a particular ID each time a change is made to the source file and subsequently deployed.

In the case of a migration, you may see the same [migration_id] repeated, but only in the scenario where the "Mark As Deployed" button/command has been run.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'migration_id';
        EXECUTE sp_addextendedproperty N'MS_Description', N'If you have enabled SQLCMD Packaging in your SQL Change Automation project, or if you are using Octopus Deploy, this will be the version number that your database package was stamped with at build-time.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'package_version';
        EXECUTE sp_addextendedproperty N'MS_Description', N'If you are using Octopus Deploy, you can use the value in this column to look-up which release was responsible for deploying this migration.
If deploying via PowerShell, set the $ReleaseVersion variable to populate this column.
If deploying via Visual Studio, this column will always be NULL.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'release_version';
        EXECUTE sp_addextendedproperty N'MS_Description', N'A SHA256 representation of the migration script file at the time of build.  This value is used to determine whether a migration has been changed since it was deployed. In the case of a programmable object script, a different checksum will cause the migration to be redeployed.
Note: if any variables have been specified as part of a deployment, this will not affect the checksum value.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'script_checksum';
        EXECUTE sp_addextendedproperty N'MS_Description', N'The name of the migration script file on disk, at the time of build.
If Semantic Versioning has been enabled, then this value will contain the full relative path from the root of the project folder. If it is not enabled, then it will simply contain the filename itself.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'script_filename';
        EXECUTE sp_addextendedproperty N'MS_Description', N'An auto-seeded numeric identifier that can be used to determine the order in which migrations were deployed.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'sequence_no';
        EXECUTE sp_addextendedproperty N'MS_Description', N'The semantic version that this migration was created under. In SQL Change Automation projects, a folder can be given a version number, e.g. 1.0.0, and one or more migration scripts can be stored within that folder to provide logical grouping of related database changes.', 'SCHEMA', N'dbo', 'TABLE', N'__MigrationLog', 'COLUMN', N'version';
        EXECUTE sp_addextendedproperty N'MS_Description', N'This view is required by SQL Change Automation projects to determine whether a migration should be executed during a deployment. The view lists the most recent [__MigrationLog] entry for a given [migration_id], which is needed to determine whether a particular programmable object script needs to be (re)executed: a non-matching checksum on the current [__MigrationLog] entry will trigger the execution of a programmable object script. Please do not alter or remove this table from the database.', N'SCHEMA', N'dbo', N'VIEW', N'__MigrationLogCurrent', NULL, NULL;
      END
  END

IF NOT EXISTS (SELECT col.COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tab, INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS col WHERE col.CONSTRAINT_NAME = tab.CONSTRAINT_NAME AND col.TABLE_NAME = tab.TABLE_NAME AND col.TABLE_SCHEMA = tab.TABLE_SCHEMA AND tab.CONSTRAINT_TYPE = 'PRIMARY KEY' AND col.TABLE_SCHEMA = 'dbo' AND col.TABLE_NAME = '__MigrationLog' AND col.COLUMN_NAME = 'complete_dt')
  BEGIN
    RAISERROR (N'The SQL Change Automation [dbo].[__MigrationLog] table has an incorrect primary key specification. This may be due to the fact that the <SqlChangeAutomationSchemaVersion/> element in your .sqlproj file contains the wrong version number for your database. Please check earlier versions of your .sqlproj file to determine what is the appropriate version for your database (possibly 1.7 or 1.3.1).', 16, 127, N'UNKNOWN')
      WITH NOWAIT;
    RETURN;
  END

IF COL_LENGTH(N'[dbo].[__MigrationLog]', N'sequence_no') IS NULL
  BEGIN
    RAISERROR (N'The SQL Change Automation [dbo].[__MigrationLog] table is missing the [sequence_no] column. This may be due to the fact that the <SqlChangeAutomationSchemaVersion/> element in your .sqlproj file contains the wrong version number for your database. Please check earlier versions of your .sqlproj file to determine what is the appropriate version for your database (possibly 1.7 or 1.3.1).', 16, 127, N'UNKNOWN')
      WITH NOWAIT;
    RETURN;
  END

IF (NOT EXISTS (SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[__MigrationLogCurrent]') AND [type] = 'V'))
  BEGIN
    EXECUTE ('
	CREATE VIEW [dbo].[__MigrationLogCurrent]
			AS
			WITH currentMigration AS
			(
			  SELECT
				 migration_id, script_checksum, script_filename, complete_dt, applied_by, deployed, ROW_NUMBER() OVER(PARTITION BY migration_id ORDER BY sequence_no DESC) AS RowNumber
			  FROM [dbo].[__MigrationLog]
			)
			SELECT  migration_id, script_checksum, script_filename, complete_dt, applied_by, deployed
			FROM currentMigration
			WHERE RowNumber = 1
	');
  END

GO
PRINT '# Setting up __SchemaSnapshot table';
IF (NOT EXISTS (SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[__SchemaSnapshot]')))
  BEGIN
    CREATE TABLE [dbo].[__SchemaSnapshot] (
      [Snapshot] VARBINARY (MAX),
      [LastUpdateDate] DATETIME2 CONSTRAINT [__SchemaSnapshotDateDefault] DEFAULT SYSDATETIME());
    IF OBJECT_ID(N'sp_addextendedproperty', 'P') IS NOT NULL
      BEGIN
        EXECUTE sp_addextendedproperty N'MS_Description', N'This table is used by SQL Change Automation projects to store a snapshot of the schema at the time of the last deployment. Please do not alter or remove this table from the database.', 'SCHEMA', N'dbo', 'TABLE', N'__SchemaSnapshot', NULL, NULL;
      END
  END

GO
PRINT '# Truncating __SchemaSnapshot';
TRUNCATE TABLE [dbo].[__SchemaSnapshot];

GO
PRINT '# Check if baseline is required';
DECLARE @baselineRequired AS BIT;

SET @baselineRequired = 0;

IF (EXISTS (SELECT * FROM sys.objects AS o WHERE o.is_ms_shipped = 0 AND NOT (o.name LIKE '%__MigrationLog%' OR o.name LIKE '%__SchemaSnapshot%')) AND (SELECT count(*) FROM [dbo].[__MigrationLog]) = 0)
  SET @baselineRequired = 1;

IF @baselineRequired = 1
  IF '$(ForceDeployWithoutBaseline)' != 'True'
    RAISERROR ('A baseline has not been set for this project, however pre-existing objects have been found in this database. Please set a baseline in the Visual Studio Project Settings, or set ForceDeployWithoutBaseline=True to continue deploying without a baseline.', 16, 127);

GO
SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;

GO
IF DB_NAME() != '$(DatabaseName)'
  USE [$(DatabaseName)];

GO
IF NOT EXISTS (SELECT 1 FROM [$(DatabaseName)].[dbo].[__MigrationLogCurrent] WHERE [migration_id] = CAST ('ae2f544d-84a6-49ed-b004-2509515f614e' AS UNIQUEIDENTIFIER))
  PRINT '

***** EXECUTING MIGRATION "Migrations\001_20220428-2023_bikram.neupane.sql", ID: {ae2f544d-84a6-49ed-b004-2509515f614e} *****';

GO
IF EXISTS (SELECT 1 FROM [$(DatabaseName)].[dbo].[__MigrationLogCurrent] WHERE [migration_id] = CAST ('ae2f544d-84a6-49ed-b004-2509515f614e' AS UNIQUEIDENTIFIER))
BEGIN
  PRINT '----- Skipping "Migrations\001_20220428-2023_bikram.neupane.sql", ID: {ae2f544d-84a6-49ed-b004-2509515f614e} as it has already been run on this database';
  SET NOEXEC ON;
END

GO
EXECUTE ('
PRINT N''Creating [dbo].[PERSON]''
');

GO
EXECUTE ('CREATE TABLE [dbo].[PERSON]
(
[PERSONID] [int] NOT NULL IDENTITY(1, 1),
[NAME] [varchar] (50) NULL
)
');

GO
EXECUTE ('PRINT N''Creating primary key [PK__PERSON__0986239EECA59E69] on [dbo].[PERSON]''
');

GO
EXECUTE ('ALTER TABLE [dbo].[PERSON] ADD CONSTRAINT [PK__PERSON__0986239EECA59E69] PRIMARY KEY CLUSTERED ([PERSONID])
');

GO
SET NOEXEC OFF;

GO
IF N'$(IsSqlCmdEnabled)' <> N'True'
  SET NOEXEC ON;

GO
IF NOT EXISTS (SELECT 1 FROM [$(DatabaseName)].[dbo].[__MigrationLogCurrent] WHERE [migration_id] = CAST ('ae2f544d-84a6-49ed-b004-2509515f614e' AS UNIQUEIDENTIFIER))
  PRINT '***** FINISHED EXECUTING MIGRATION "Migrations\001_20220428-2023_bikram.neupane.sql", ID: {ae2f544d-84a6-49ed-b004-2509515f614e} *****
';

GO
IF NOT EXISTS (SELECT 1 FROM [$(DatabaseName)].[dbo].[__MigrationLogCurrent] WHERE [migration_id] = CAST ('ae2f544d-84a6-49ed-b004-2509515f614e' AS UNIQUEIDENTIFIER))
  INSERT [$(DatabaseName)].[dbo].[__MigrationLog] ([migration_id], [script_checksum], [script_filename], [complete_dt], [applied_by], [deployed], [version], [package_version], [release_version])
  VALUES                                         (CAST ('ae2f544d-84a6-49ed-b004-2509515f614e' AS UNIQUEIDENTIFIER), 'ACB2008003AB03B133B5D434023C8722A0B353CFDF887E389195FFA99907AEF4', 'Migrations\001_20220428-2023_bikram.neupane.sql', SYSDATETIME(), SYSTEM_USER, 1, NULL, '$(PackageVersion)', CASE '$(ReleaseVersion)' WHEN '' THEN NULL ELSE '$(ReleaseVersion)' END);

GO
SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;

GO
IF DB_NAME() != '$(DatabaseName)'
  USE [$(DatabaseName)];

GO
IF NOT EXISTS (SELECT 1 FROM [$(DatabaseName)].[dbo].[__MigrationLogCurrent] WHERE [migration_id] = CAST ('e29068fc-f879-53c0-ae3c-67423b967176' AS UNIQUEIDENTIFIER) AND [script_checksum] = '3B1489517507000A24FADDCB29C77C94AD9C63DFB04713D5207773C272D8821A')
  PRINT '

***** EXECUTING MIGRATION "Programmable Objects\dbo\Stored Procedures\SpBikramAutomationCheck.sql", ID: {e29068fc-f879-53c0-ae3c-67423b967176} *****';

GO
IF EXISTS (SELECT 1 FROM [$(DatabaseName)].[dbo].[__MigrationLogCurrent] WHERE [migration_id] = CAST ('e29068fc-f879-53c0-ae3c-67423b967176' AS UNIQUEIDENTIFIER) AND [script_checksum] = '3B1489517507000A24FADDCB29C77C94AD9C63DFB04713D5207773C272D8821A')
BEGIN
  PRINT '----- Skipping "Programmable Objects\dbo\Stored Procedures\SpBikramAutomationCheck.sql", ID: {e29068fc-f879-53c0-ae3c-67423b967176} as there are no changes to deploy';
  SET NOEXEC ON;
END

GO
EXECUTE ('IF OBJECT_ID(''[dbo].[SpBikramAutomationCheck]'') IS NOT NULL
	DROP PROCEDURE [dbo].[SpBikramAutomationCheck];

');

GO
SET QUOTED_IDENTIFIER ON

GO
SET ANSI_NULLS ON

GO
EXECUTE ('-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpBikramAutomationCheck]
		(@json NVARCHAR(MAX))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		 
			SELECT @json
			 
END
');

GO
SET NOEXEC OFF;

GO
IF N'$(IsSqlCmdEnabled)' <> N'True'
  SET NOEXEC ON;

GO
IF NOT EXISTS (SELECT 1 FROM [$(DatabaseName)].[dbo].[__MigrationLogCurrent] WHERE [migration_id] = CAST ('e29068fc-f879-53c0-ae3c-67423b967176' AS UNIQUEIDENTIFIER) AND [script_checksum] = '3B1489517507000A24FADDCB29C77C94AD9C63DFB04713D5207773C272D8821A')
  PRINT '***** FINISHED EXECUTING MIGRATION "Programmable Objects\dbo\Stored Procedures\SpBikramAutomationCheck.sql", ID: {e29068fc-f879-53c0-ae3c-67423b967176} *****
';

GO
IF NOT EXISTS (SELECT 1 FROM [$(DatabaseName)].[dbo].[__MigrationLogCurrent] WHERE [migration_id] = CAST ('e29068fc-f879-53c0-ae3c-67423b967176' AS UNIQUEIDENTIFIER) AND [script_checksum] = '3B1489517507000A24FADDCB29C77C94AD9C63DFB04713D5207773C272D8821A')
  INSERT [$(DatabaseName)].[dbo].[__MigrationLog] ([migration_id], [script_checksum], [script_filename], [complete_dt], [applied_by], [deployed], [version], [package_version], [release_version])
  VALUES                                         (CAST ('e29068fc-f879-53c0-ae3c-67423b967176' AS UNIQUEIDENTIFIER), '3B1489517507000A24FADDCB29C77C94AD9C63DFB04713D5207773C272D8821A', 'Programmable Objects\dbo\Stored Procedures\SpBikramAutomationCheck.sql', SYSDATETIME(), SYSTEM_USER, 1, NULL, '$(PackageVersion)', CASE '$(ReleaseVersion)' WHEN '' THEN NULL ELSE '$(ReleaseVersion)' END);

GO
PRINT '# Committing transaction';

COMMIT TRANSACTION;

GO







------------------------------------------------------------------------------------------------------------------------
------------------------------------------       POST-DEPLOYMENT SCRIPTS      ------------------------------------------
------------------------------------------------------------------------------------------------------------------------

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;
IF DB_NAME() != '$(DatabaseName)'
  USE [$(DatabaseName)];

GO

PRINT '----- executing post-deployment script "Post-Deployment\01_Finalize_Deployment.sql" -----';
GO

---------------------- BEGIN POST-DEPLOYMENT SCRIPT: "Post-Deployment\01_Finalize_Deployment.sql" ------------------------
/*
Post-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.
 Use SQLCMD syntax to include a file in the post-deployment script.
 Example:      :r .\myfile.sql
 Use SQLCMD syntax to reference a variable in the post-deployment script.
 Example:      :setvar TableName MyTable
               SELECT * FROM [$(TableName)]
--------------------------------------------------------------------------------------
*/

:r Post-Deployment/02_bikram_deployment.sql
 
GO
----------------------- END POST-DEPLOYMENT SCRIPT: "Post-Deployment\01_Finalize_Deployment.sql" -------------------------

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;
IF DB_NAME() != '$(DatabaseName)'
  USE [$(DatabaseName)];

GO

PRINT '----- executing post-deployment script "Post-Deployment\02_bikram_deployment.sql" -----';
GO

----------------------- BEGIN POST-DEPLOYMENT SCRIPT: "Post-Deployment\02_bikram_deployment.sql" -------------------------


INSERT INTO dbo.PERSON
(
    NAME
)
VALUES
('bikram' -- NAME - varchar(50)
    )
GO
------------------------ END POST-DEPLOYMENT SCRIPT: "Post-Deployment\02_bikram_deployment.sql" --------------------------

SET IMPLICIT_TRANSACTIONS, NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, NOCOUNT, QUOTED_IDENTIFIER ON;
IF DB_NAME() != '$(DatabaseName)'
  USE [$(DatabaseName)];

GO


IF SERVERPROPERTY('EngineEdition') != 5 AND HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
  DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
  SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
  SET @eventMessage = N'Redgate SQL Change Automation: { "deployment": { "description": "Redgate SQL Change Automation deployed $(ReleaseVersion) to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
  EXECUTE sys.xp_logevent 55000, @eventMessage
END
PRINT 'Deployment completed successfully.'
GO




SET NOEXEC OFF; -- Resume statement execution if an error occurred within the script pre-amble
