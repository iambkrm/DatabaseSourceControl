IF OBJECT_ID('[dbo].[SpUserLogIns]') IS NOT NULL
	DROP PROCEDURE [dbo].[SpUserLogIns];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		samar
-- Create date: 07/19/2019
-- Description:	UserLog Information
-- =============================================
-- =============================================
-- Modified:	Priyanka Khadgi
-- Create date: 03/30/2021
-- Description:	Added logic to track failed login attempts.
-- =============================================
CREATE PROCEDURE [dbo].[SpUserLogIns]
(
    @PersonId INT ,
    @UserName NVARCHAR (100) ,
    @DeviceInfo VARCHAR (2500) ,
    @IsFailedLogin BIT ,
    @Source VARCHAR (50) ,
    @FailedLoginCount INT OUTPUT )
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @LockedStatusListItemId INT = [dbo].[SfListItemIdGet] ('Status', 'Locked');
        DECLARE @ActiveStatusListItemId INT = [dbo].[SfListItemIdGet] ('Status', 'Active');
        DECLARE @TodaysDate DATETIME = GETDATE ();
        DECLARE @AutomationUserPersonId INT = dbo.SfAutomationUserPersonIdGet ();

        IF @IsFailedLogin = 1
            BEGIN
                IF EXISTS ( SELECT TOP 1 1
                            FROM   dbo.WHUserLog AS ul
                            WHERE  ( ( @PersonId > 0
                                   AND ul.PersonId = @PersonId )
                                  OR ( @PersonId = 0
                                   AND ul.UserName = @UserName ))
                            AND    CONVERT (DATE, ul.InsertDate) = CONVERT (DATE, @TodaysDate))
                    BEGIN
                        SELECT   TOP 1 @FailedLoginCount = ul.FailedLoginCount
                        FROM     dbo.WHUserLog AS ul
                        WHERE    ( ( @PersonId > 0
                                 AND ul.PersonId = @PersonId )
                                OR ( @PersonId = 0
                                 AND ul.UserName = @UserName ))
                        AND      CONVERT (DATE, ul.InsertDate) = CONVERT (DATE, @TodaysDate)
                        ORDER BY ul.UserLogId DESC;
                    END;
                ELSE
                    BEGIN
                        SELECT   TOP 1 @FailedLoginCount = ul.FailedLoginCount
                        FROM     dbo.WHUserLog AS ul
                        WHERE    ( ( @PersonId > 0
                                 AND ul.PersonId = @PersonId )
                                OR ( @PersonId = 0
                                 AND ul.UserName = @UserName ))
                        ORDER BY ul.UserLogId DESC;

                        IF @FailedLoginCount < 5
                            BEGIN
                                SET @FailedLoginCount = 0;
                            END;
                    END;

                IF EXISTS ( SELECT TOP 1 1
                            FROM   dbo.[User] AS u
                            WHERE  u.PersonId = @PersonId
                            AND    u.StatusListItemId = @ActiveStatusListItemId
                            AND    @FailedLoginCount >= 5 )
                    BEGIN
                        SET @FailedLoginCount = 0;
                    END;

                SET @FailedLoginCount = @FailedLoginCount + 1;

                IF  @FailedLoginCount >= 5
                AND @PersonId <> @AutomationUserPersonId --added by priyanka; 06/22/2021; added condition so that automation user will not be locked
                    BEGIN
                        UPDATE u
                        SET    u.StatusListItemId = @LockedStatusListItemId
                        FROM   dbo.[User] AS u
                        WHERE  u.PersonId = @PersonId;
                    END;
            END;

        INSERT dbo.WHUserLog ( PersonId ,
                               DeviceInfo ,
                               FailedLoginCount ,
                               UserName ,
                               Source )
        VALUES ( @PersonId, @DeviceInfo, @FailedLoginCount, @UserName, @Source );

    END;

GO
