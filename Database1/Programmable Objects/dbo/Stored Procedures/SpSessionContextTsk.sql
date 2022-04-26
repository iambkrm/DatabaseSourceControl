IF OBJECT_ID('[dbo].[SpSessionContextTsk]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpSessionContextTsk];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		samar
-- Create date: 07/17/2019
-- Description:	<Description,,>
-- =============================================
-- ===================================================================
-- Modified by : Mrijan
-- Modified date: 03/03/2021
-- Description : " AND    u.DeviceInfo <> @DeviceInfo" logic insert
-- ===================================================================
CREATE PROCEDURE [dbo].[SpSessionContextTsk]
(
    @Json NVARCHAR (MAX))
AS
    BEGIN
        SET NOCOUNT ON;
        --WAITFOR DELAY '00:00:02';

        DECLARE @Key sysname;
        DECLARE @Value SQL_VARIANT;
        DECLARE @MinId TINYINT = 0;
        DECLARE @MaxId TINYINT = 0;

        DECLARE @t TABLE
        (   Id INT IDENTITY (1, 1) ,
            [Key] VARCHAR (100) ,
            [Value] NVARCHAR (2500));
        INSERT @t ( [Key] ,
                    Value )
               SELECT t.[Key] ,
                      t.Value
               FROM   OPENJSON (REPLACE (REPLACE (@Json, '[', ''), ']', '')) AS t;

        SELECT @MaxId = MAX (t.Id) ,
               @MinId = MIN (t.Id)
        FROM   @t t;

        WHILE ( @MinId <= @MaxId )
            BEGIN

                SELECT @Key = LOWER (t.[Key]) ,
                       @Value = t.Value
                FROM   @t t
                WHERE  t.Id = @MinId;

                IF ( @Key <> 'deviceInfo' )
                    BEGIN
                        EXEC sys.sp_set_session_context @Key = @Key ,
                                                        @Value = @Value ,
                                                        @read_only = 0;
                    END;
                SET @MinId = @MinId + 1;
            END;

        DECLARE @PersonId INT = dbo.SfPersonIdGet ();
        DECLARE @DeviceInfo VARCHAR (2500);
        DECLARE @Source VARCHAR (50) = 'Session';

        SELECT @DeviceInfo = t.Value
        FROM   @t AS t
        WHERE  t.[Key] = 'deviceInfo';

        DECLARE @Date DATE = GETDATE ();

        SELECT @DeviceInfo = ISNULL (@DeviceInfo, 'no device info found.');

        IF ( @PersonId > 0 )
            BEGIN
                IF NOT EXISTS ( SELECT TOP 1 1
                                FROM   dbo.WHUserLog u
                                --INNER JOIN dbo.Person os ON u.PersonId = os.PersonId
                                WHERE  CAST(u.InsertDate AS DATE) = @Date
                                AND    u.PersonId = @PersonId
                                AND    u.DeviceInfo = @DeviceInfo )
                    BEGIN
                        DECLARE @FailedLoginCount INT = 0;
                        DECLARE @UserName NVARCHAR (100) = ( SELECT u.UserName
                                                             FROM   dbo.[User] AS u
                                                             WHERE  u.PersonId = @PersonId );
                        EXEC dbo.SpUserLogIns @PersonId = @PersonId ,
                                              @UserName = @UserName ,
                                              @DeviceInfo = @DeviceInfo ,
                                              @IsFailedLogin = 0 ,
                                              @Source = @Source ,
                                              @FailedLoginCount = @FailedLoginCount OUTPUT;

                    END;
            END;

    --IF NOT EXISTS
    --(
    --    SELECT TOP 1
    --        1
    --    FROM dbo.WHUserLog u
    --        INNER JOIN dbo.Person os
    --            ON u.PersonId = os.PersonId
    --              AND CAST(u.InsertDate AS DATE) = CAST(GETDATE() AS DATE)
    --               AND os.PersonId = @PersonId
    --)
    --BEGIN
    --    EXEC dbo.WHSpUserLogIns @PersonId = @PersonId,
    --                                 @DeviceInfo = @DeviceInfo;
    --END;

    /*
        IF ( @PersonId > 0
         AND LEN (@DeviceInfo) > 10 )
            BEGIN
                EXEC dbo.SpUserLogIns @PersonId = @PersonId ,
                                      @DeviceInfo = @DeviceInfo;
            END;
    			*/
    END;








GO
