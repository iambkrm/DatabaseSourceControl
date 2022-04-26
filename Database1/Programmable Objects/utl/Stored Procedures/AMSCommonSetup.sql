IF OBJECT_ID('[utl].[AMSCommonSetup]') IS NOT NULL
	DROP PROCEDURE [utl].[AMSCommonSetup];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sudeep Shrestha
-- Create date: 6/26/2019
-- Description:	<AMS Common Setup Script>
-- =============================================
CREATE PROCEDURE [utl].[AMSCommonSetup]
(
    @ApplicationId INT )
AS
    BEGIN
        SET NOCOUNT ON;

        BEGIN TRY
            EXEC dbo.SpSessionContextTsk @Json = N'{"personId": 1}';
            DECLARE @Json VARCHAR (MAX);

            --Resource
            DECLARE @ResourceId INT = 0;
            SELECT @ResourceId = dbo.SfResourceIdGet ('Unmapped');

            --GeneralNavigation
            DECLARE @GeneralNavigationId INT = 0;
            SELECT @GeneralNavigationId = n.NavigationId
            FROM   dbo.Navigation AS n
            WHERE  n.Navigation = 'General';
			DECLARE @AMSApplicationId INT = dbo.SfApplicationIdGet('AMS')

            BEGIN TRANSACTION;

            -- 1. Role
            BEGIN
                DECLARE @SuperAdminRoleId INT = 0;
                SELECT @SuperAdminRoleId = dbo.SfRoleIdGet ('SuperAdmin');

                DECLARE @AdminRoleId INT = 0;
                SELECT @AdminRoleId = dbo.SfRoleIdGet ('Admin');
            END;

            --2. Navigation
            BEGIN
                SELECT @Json = '[
				{"navigation":"Snapshot","uRL":"assignment/snapshot","isExternal":0,"parentNavigationName":"Assignment","parentURL":"assignment/directory","navigationType":"Item",
			"rootNavigationName":"General","icon":"camera_front","displayOrder":1,"resourceId":'
                               + CAST(@ResourceId AS VARCHAR (MAX))
                               + '} ,
							   				 						 					
			 {"navigation":"AssignmentRate","uRL":"assignment/assignment-rate","isExternal":0,"parentNavigationName":"Assignment","parentURL":"assignment/directory","navigationType":"Item",
			"rootNavigationName":"General","icon":"attach_money","displayOrder":2,"resourceId":'
                               + CAST(@ResourceId AS VARCHAR (MAX))
                               + '},	
							   
							   {"navigation":"UserType","uRL":"assignment/user-type","isExternal":0,"parentNavigationName":"Assignment","parentURL":"assignment/directory","navigationType":"Item",
			"rootNavigationName":"General","icon":"","displayOrder":3,"resourceId":'
                               + CAST(@ResourceId AS VARCHAR (MAX))
                               + '},		    

			    {"navigation":"Comment","uRL":"assignment/comment","isExternal":0,"parentNavigationName":"Assignment","parentURL":"assignment/directory","navigationType":"Item",
			"rootNavigationName":"General","icon":"comment","displayOrder":4,"resourceId":'
                               + CAST(@ResourceId AS VARCHAR (MAX))
                               + '},

			{"navigation":"PayHistory","uRL":"assignment/pay-history","isExternal":0,"parentNavigationName":"Assignment","parentURL":"assignment/directory","navigationType":"Item",
			"rootNavigationName":"General","icon":"","displayOrder":5,"resourceId":'
                               + CAST(@ResourceId AS VARCHAR (MAX))
                               + '},
							   
							   {"navigation":"Custom","uRL":"assignment/custom","isExternal":0,"parentNavigationName":"Assignment","parentURL":"assignment/directory","navigationType":"Item",
			"rootNavigationName":"General","icon":"camera_front","displayOrder":6,"resourceId":'
                               + CAST(@ResourceId AS VARCHAR (MAX))
                               + '}  ,

							   							   {"navigation":"WorkInjury","uRL":"assignment/work-injury","isExternal":0,"parentNavigationName":"Assignment","parentURL":"assignment/directory","navigationType":"Item",
			"rootNavigationName":"General","icon":"","displayOrder":7,"resourceId":'
                               + CAST(@ResourceId AS VARCHAR (MAX)) + '} 

							     ]';


                EXEC dbo.SpNavigationNewTsk @Json = @Json;


            END;

            BEGIN
                DECLARE @AMSDashboardNavigationId INT = 0;
                SELECT @AMSDashboardNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'Dashboard'
                AND    n.URL = 'assignment/dashboard'
                AND    n.ParentNavigationId = @GeneralNavigationId;

                DECLARE @AMSAssignmentNavigationId INT = 0;
                SELECT @AMSAssignmentNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'Assignment'
                AND    n.URL = 'assignment/directory'
                AND    n.ParentNavigationId = @GeneralNavigationId;

                DECLARE @AMSAssignmentSnapshotNavigationId INT = 0;
                SELECT @AMSAssignmentSnapshotNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'Snapshot'
                AND    n.URL = 'assignment/snapshot'
                AND    n.ParentNavigationId = @AMSAssignmentNavigationId;


                DECLARE @AMSAssignmentRateNavigationId INT = 0;
                SELECT @AMSAssignmentRateNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'AssignmentRate'
                AND    n.URL = 'assignment/assignment-rate'
                AND    n.ParentNavigationId = @AMSAssignmentNavigationId;

                DECLARE @AMSUserTypeNavigationId INT = 0;
                SELECT @AMSUserTypeNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'UserType'
                AND    n.URL = 'assignment/user-type'
                AND    n.ParentNavigationId = @AMSAssignmentNavigationId;

                DECLARE @AMSCommentNavigationId INT = 0;
                SELECT @AMSCommentNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'Comment'
                AND    n.URL = 'assignment/comment'
                AND    n.ParentNavigationId = @AMSAssignmentNavigationId;

                DECLARE @AMSPayHistoryNavigationId INT = 0;
                SELECT @AMSPayHistoryNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'PayHistory'
                AND    n.URL = 'assignment/pay-history'
                AND    n.ParentNavigationId = @AMSAssignmentNavigationId;


                DECLARE @AMSAssignmentCustomNavigationId INT;
                SELECT @AMSAssignmentCustomNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'Custom'
                AND    n.URL = 'assignment/custom'
                AND    n.ParentNavigationId = @AMSAssignmentNavigationId;

                DECLARE @AMSWorkInjuryNavigationId INT;
                SELECT @AMSWorkInjuryNavigationId = n.NavigationId
                FROM   dbo.Navigation AS n
                WHERE  n.Navigation = 'WorkInjury'
                AND    n.URL = 'assignment/work-injury'
                AND    n.ParentNavigationId = @AMSAssignmentNavigationId;

            END;

            --2.ApplicationRoleNavigation

            BEGIN

                DECLARE @AMSSuperAdminApplicationRoleId INT = 0;
                SELECT @AMSSuperAdminApplicationRoleId = ar.ApplicationRoleId
                FROM   dbo.ApplicationRole AS ar
                WHERE  ar.ApplicationId = @ApplicationId
                AND    ar.RoleId = @SuperAdminRoleId;

                DECLARE @AMSAdminApplicationRoleId INT = 0;
                SELECT @AMSAdminApplicationRoleId = ar.ApplicationRoleId
                FROM   dbo.ApplicationRole AS ar
                WHERE  ar.ApplicationId = @ApplicationId
                AND    ar.RoleId = @AdminRoleId;


                DECLARE @AMSSuperAdminApplicationNavigationList VARCHAR (MAX);
                SELECT @AMSSuperAdminApplicationNavigationList = '[
				{ "navigationId" :' + CONVERT (VARCHAR (MAX), @AMSAssignmentSnapshotNavigationId)
                                                                 + ', "displayOrder" :1},

                                                               { "navigationId" :'
                                                                 + CONVERT (
                                                                       VARCHAR (MAX), @AMSAssignmentRateNavigationId)
                                                                 + ', "displayOrder" :2},																                                                               
                  
                                                                 { "navigationId" :'
                                                                 + CONVERT (VARCHAR (MAX), @AMSUserTypeNavigationId)
                                                                 + ', "displayOrder" :3},

                                                                 { "navigationId" :'
                                                                 + CONVERT (VARCHAR (MAX), @AMSCommentNavigationId)
                                                                 + ', "displayOrder" :4},

                                                                 { "navigationId" :'
                                                                 + CONVERT (VARCHAR (MAX), @AMSPayHistoryNavigationId)
                                                                 + ', "displayOrder" :5} ,
																 
																 { "navigationId" :'
                                                                 + CONVERT (
                                                                       VARCHAR (MAX), @AMSAssignmentCustomNavigationId)
                                                                 + ', "displayOrder" :6} ,
																 
																 { "navigationId" :'
                                                                 + CONVERT (VARCHAR (MAX), @AMSWorkInjuryNavigationId)
                                                                 + ', "displayOrder" :7
																 }                                                           

																 ]';





                DECLARE @AMSAdminApplicationNavigationList VARCHAR (MAX);
                SELECT @AMSAdminApplicationNavigationList = '[{ "navigationId" :'
                                                            + CONVERT (
                                                                  VARCHAR (MAX), @AMSAssignmentSnapshotNavigationId)
                                                            + ', "displayOrder" :1},

                                                               { "navigationId" :'
                                                            + CONVERT (VARCHAR (MAX), @AMSAssignmentRateNavigationId)
                                                            + ', "displayOrder" :2},																                                                               
                  
                                                                 { "navigationId" :'
                                                            + CONVERT (VARCHAR (MAX), @AMSUserTypeNavigationId)
                                                            + ', "displayOrder" :3},

                                                                 { "navigationId" :'
                                                            + CONVERT (VARCHAR (MAX), @AMSCommentNavigationId)
                                                            + ', "displayOrder" :4},

                                                                 { "navigationId" :'
                                                            + CONVERT (VARCHAR (MAX), @AMSPayHistoryNavigationId)
                                                            + ', "displayOrder" :5}   ,
															
															{ "navigationId" :'
                                                            + CONVERT (VARCHAR (MAX), @AMSAssignmentCustomNavigationId)
                                                            + ', "displayOrder" :6} ,
																 { "navigationId" :'
                                                            + CONVERT (VARCHAR (MAX), @AMSWorkInjuryNavigationId)
                                                            + ', "displayOrder" :7
																 }                                                           

																 ]';

                SELECT @Json = '[
				
							     {"applicationRoleId":' + CAST(@AMSSuperAdminApplicationRoleId AS VARCHAR (15))
                               + ',"navigationIdList":' + @AMSSuperAdminApplicationNavigationList
                               +', "parentApplicationId": ' + CAST(@AMSApplicationId AS VARCHAR (15)) + '},

							                   {"applicationRoleId":'
                               + CAST(@AMSAdminApplicationRoleId AS VARCHAR (15)) + ',"navigationIdList":'
                               + @AMSAdminApplicationNavigationList + ', "parentApplicationId": ' + CAST(@AMSApplicationId AS VARCHAR (15)) + '} ]';
							   EXEC dbo.SpApplicationNavigationIns @Json = @Json;
                EXEC dbo.SpApplicationRoleNavigationIns @Json = @Json;

            END;

            --.NavigationAction and ApplicationRoleNavigationAction
            BEGIN
                SELECT @Json = '[
				{"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add Assignment",
 "navigationActionType":"Independent", "resource": "Unmapped", "applicationId":'
                               + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "add" },

 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add Assignment",
 "navigationActionType":"Independent", "resource": "Unmapped", "applicationId":'
                               + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "add" },


{"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit Assignment",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "edit" },

 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit Assignment",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "edit" },
	
 
 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh Assignment",
 "navigationActionType":"SingleAndMultiple", "resource": "Unmapped", "applicationId":'
                               + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "refresh" },

 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh Assignment",
 "navigationActionType":"SingleAndMultiple", "resource": "Unmapped", "applicationId":'
                               + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "refresh" },	
							
			
			
 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Single","description": "New Work Injury",
 "navigationActionType":"SingleAndMultiple", "resource": "Unmapped", "applicationId":'
                               + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "add_circle_outline" },

 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"NewWorkInjury","description": "New Work Injury",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "add_circle_outline" },


{"navigationId":' + CAST(@AMSAssignmentRateNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "add" },

 {"navigationId":' + CAST(@AMSAssignmentRateNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "add" },



 {"navigationId":' + CAST(@AMSAssignmentRateNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "edit" },

 {"navigationId":' + CAST(@AMSAssignmentRateNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "edit" },


  {"navigationId":' + CAST(@AMSAssignmentRateNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "refresh" },

 {"navigationId":' + CAST(@AMSAssignmentRateNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "refresh" },


 {"navigationId":' + CAST(@AMSUserTypeNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "add" },

 {"navigationId":' + CAST(@AMSUserTypeNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "add" },



 {"navigationId":' + CAST(@AMSUserTypeNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "edit" },

 {"navigationId":' + CAST(@AMSUserTypeNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "edit" },


  {"navigationId":' + CAST(@AMSUserTypeNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "refresh" },

 {"navigationId":' + CAST(@AMSUserTypeNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "refresh" },


  {"navigationId":' + CAST(@AMSCommentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "add" },

 {"navigationId":' + CAST(@AMSCommentNavigationId AS VARCHAR (MAX))
                               + ',"action":"View","description": "View",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "play_arrow" },

{"navigationId":' + CAST(@AMSCommentNavigationId AS VARCHAR (MAX))
                               + ',"action":"View","description": "View",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "play_arrow" },

 {"navigationId":' + CAST(@AMSCommentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "add" },




 {"navigationId":' + CAST(@AMSCommentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "edit" },

 {"navigationId":' + CAST(@AMSCommentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "edit" },



  {"navigationId":' + CAST(@AMSCommentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "refresh" },

 {"navigationId":' + CAST(@AMSCommentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "refresh" },



 {"navigationId":' + CAST(@AMSPayHistoryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"SingleAndMultiple", "resource": "Unmapped", "applicationId":'
                               + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "refresh" },

 {"navigationId":' + CAST(@AMSPayHistoryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"SingleAndMultiple", "resource": "Unmapped", "applicationId":'
                               + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "refresh" },

 	{"navigationId":' + CAST(@AMSAssignmentCustomNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add Custom",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "add" },

 {"navigationId":' + CAST(@AMSAssignmentCustomNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add Custom",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "add" },

 {"navigationId":' + CAST(@AMSAssignmentCustomNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit Custom",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "edit" },

 {"navigationId":' + CAST(@AMSAssignmentCustomNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit Custom",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "edit" },

  {"navigationId":' + CAST(@AMSAssignmentCustomNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh Custom",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "refresh" },

 {"navigationId":' + CAST(@AMSAssignmentCustomNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh Custom",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "refresh" },

  {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "add" },

 {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "add" },

 {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "ServiceRep", "icon" : "add" },

  {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Add","description": "Add",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "PayAdmin", "icon" : "add" },


 {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "edit" },

 {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "edit" },

 {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "ServiceRep", "icon" : "edit" },

  {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Edit","description": "Edit",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "PayAdmin", "icon" : "edit" },

  {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "refresh" },

 {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "refresh" },

 {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "ServiceRep", "icon" : "refresh" },

  {"navigationId":' + CAST(@AMSWorkInjuryNavigationId AS VARCHAR (MAX))
                               + ',"action":"Refresh","description": "Refresh",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "PayAdmin", "icon" : "refresh" },

  {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"copyAssignment","description": "Copy Assignment",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "SuperAdmin", "icon" : "file_copy" },

 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"copyAssignment","description": "Copy Assignment",
 "navigationActionType":"Single", "resource": "Unmapped", "applicationId":' + CAST(@ApplicationId AS VARCHAR (MAX))
                               + ', "role": "Admin", "icon" : "file_copy" },

																  {"navigationId":'
                               + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Email","description": "Email",
 "navigationActionType":"Single", "resource": "Unmapped", "application":"AMS", "role": "SuperAdmin", "icon" : "email" },

 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"Email","description": "Email",
 "navigationActionType":"Single", "resource": "Unmapped", "application":"AMS", "role": "Admin", "icon" : "email" },


   {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"SMS","description": "SMS",
 "navigationActionType":"Single", "resource": "Unmapped", "application":"AMS", "role": "SuperAdmin", "icon" : "sms" },

 {"navigationId":' + CAST(@AMSAssignmentNavigationId AS VARCHAR (MAX))
                               + ',"action":"SMS","description": "SMS",
 "navigationActionType":"Single", "resource": "Unmapped", "application":"AMS", "role": "Admin", "icon" : "sms" }


 ]'             ;

                EXEC dbo.SpNavigationActionNewTsk @Json = @Json;


            END;

            --6.Option
            BEGIN

                -------AssignmentRate
                DECLARE @AssignmentRateAddNavigationActionId INT = 0;
                SELECT @AssignmentRateAddNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/assignment-rate'
                AND    na.Action = 'Add';

                DECLARE @AssignmentRateEditNavigationActionId INT = 0;
                SELECT @AssignmentRateEditNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/assignment-rate'
                AND    na.Action = 'Edit';


                -------UserType
                DECLARE @UserTypeAddNavigationActionId INT = 0;
                SELECT @UserTypeAddNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/user-type'
                AND    na.Action = 'Add';

                DECLARE @UserTypeEditNavigationActionId INT = 0;
                SELECT @UserTypeEditNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/user-type'
                AND    na.Action = 'Edit';


                -------Comment
                DECLARE @CommentAddNavigationActionId INT = 0;
                SELECT @CommentAddNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/comment'
                AND    na.Action = 'Add';

                DECLARE @CommentEditNavigationActionId INT = 0;
                SELECT @CommentEditNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/comment'
                AND    na.Action = 'Edit';


                -------PayHistory
                DECLARE @PayHistoryRefreshNavigationActionId INT = 0;
                SELECT @PayHistoryRefreshNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/pay-history'
                AND    na.Action = 'Refresh';



                DECLARE @AssignmentCustomAddNavigationActionId INT;
                SELECT @AssignmentCustomAddNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/custom'
                AND    na.Action = 'Add';

                DECLARE @AssignmentCustomEditNavigationActionId INT;
                SELECT @AssignmentCustomEditNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/custom'
                AND    na.Action = 'Edit';

                -------workinjury
                DECLARE @workInjuryAddNavigationActionId INT;
                SELECT @workInjuryAddNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/work-injury'
                AND    na.Action = 'Add';

                DECLARE @workInjuryEditNavigationActionId INT;
                SELECT @workInjuryEditNavigationActionId = na.NavigationActionId
                FROM   dbo.NavigationAction AS na
                       INNER JOIN dbo.Navigation AS n ON n.NavigationId = na.NavigationId
                WHERE  n.URL = 'assignment/work-injury'
                AND    na.Action = 'Edit';

                DECLARE @RegularAssignmentTypeListItemId INT = dbo.SfListItemIdGet ('AssignmentType', 'Regular');

                SELECT @Json = '[
				
							  {"option":"JobCandidate",
										"optionProperty":"EmailProfileId",
										  "entity":"Organization",
										  "dataType":"String",
										  "allowOverride":1,
										  "defaultValue":"0",
										  "isMultiValue":0,
										  "source":"0"
										},
									{"option":"Assignment",
									  "optionProperty":"DetailFavoriteAction",
									  "entity":"Person",
									   "dataType":"MultiSelect",
									  "allowOverride":1,
									  "defaultValue":"0",
									  "isMultiValue":1,
									  "source":""
									},

							  {"option":"Assignment",
							"optionProperty":"AssignmentRateFavoriteAction",
							  "entity":"Person",
							   "dataType":"MultiSelect",
							  "allowOverride":1,
							  "defaultValue":"' + CAST(@AssignmentRateAddNavigationActionId AS VARCHAR (MAX)) + ','
                               + CAST(@AssignmentRateEditNavigationActionId AS VARCHAR (MAX))
                               + '",
							  "isMultiValue":1,
							  "source":""
							  },							
							
							  {
							  "option":"Assignment",
							"optionProperty":"UserTypeFavoriteAction",
							  "entity":"Person",
							   "dataType":"MultiSelect",
							  "allowOverride":1,
							  "defaultValue":"' + CAST(@UserTypeAddNavigationActionId AS VARCHAR (MAX)) + ','
                               + CAST(@UserTypeEditNavigationActionId AS VARCHAR (MAX))
                               + '",
							  "isMultiValue":1,
							  "source":""
							  }	,


							  {
							  "option":"Assignment",
							"optionProperty":"CommentFavoriteAction",
							  "entity":"Person",
							   "dataType":"MultiSelect",
							  "allowOverride":1,
							  "defaultValue":"' + CAST(@CommentAddNavigationActionId AS VARCHAR (MAX)) + ','
                               + CAST(@CommentEditNavigationActionId AS VARCHAR (MAX))
                               + '",
							  "isMultiValue":1,
							  "source":""
							  }	,

							  {"option":"Assignment",
										"optionProperty":"PayHistoryFavoriteAction",
										  "entity":"Person",
										  "dataType":"MultiSelect",
										  "allowOverride":1,
										  "defaultValue":"'
                               + CAST(@PayHistoryRefreshNavigationActionId AS VARCHAR (MAX))
                               + '",
										  "isMultiValue":0,
										  "source":""
										}	,
																				
										{"option":"Assignment",
										"optionProperty":"FilterStatus",
										  "entity":"Person",
										   "dataType":"Select",
										  "allowOverride":0,
										  "defaultValue":"Disable",
										  "isMultiValue":0,
										  "source":"Disable,Enable"
										  },
										  {"option":"Assignment",
										  "optionProperty":"StatusFilter",
										  "entity":"Person",
										   "dataType":"MultiSelect",
										  "allowOverride":1,
										  "defaultValue":"0",
										  "isMultiValue":1,
										  "source":"0"
										}	,
										
										{"option":"Assignment",
										"optionProperty":"EmployeeAssignmentEmailTemplateId",
										  "entity":"Organization",
										  "dataType":"String",
										  "showInUI":0,
										  "allowOverride":"0",
										  "defaultValue":0,
										  "source":"0"
										}	,
										{"option":"Assignment",
										"optionProperty":"EmailProfileId",
										  "entity":"Office",
										  "dataType":"String",
										  "allowOverride":1,
										  "defaultValue":"0",
										  "isMultiValue":0,
										  "source":"0"
										},

										{"option":"Assignment",
							"optionProperty":"CustomFavoriteAction",
							  "entity":"Person",
							   "dataType":"MultiSelect",
							  "allowOverride":1,
							  "defaultValue":"' + CAST(@AssignmentCustomAddNavigationActionId AS VARCHAR (MAX)) + ','
                               + CAST(@AssignmentCustomEditNavigationActionId AS VARCHAR (MAX))
                               + '",
							  "isMultiValue":1,
							  "source":""
							  }	,
							  {
					    "option": "Assignment",
					    "optionProperty": "AssignmentType",
					    "entity": "Person",
						"dataType":"MultiSelect",
					    "showInUI":1,
					    "defaultValue": "' + CAST(@RegularAssignmentTypeListItemId AS VARCHAR (25))
                               + '",
					    
					   "source":""
					  }		,
					  {
							  "option":"WorkInjury",
							"optionProperty":"workInjuryFavoriteAction",
							  "entity":"Person",
							   "dataType":"MultiSelect",
							  "allowOverride":1,
							  "defaultValue":"' + CAST(@workInjuryAddNavigationActionId AS VARCHAR (MAX)) + ','
                               + CAST(@workInjuryEditNavigationActionId AS VARCHAR (MAX))
                               + '",
							  "isMultiValue":1,
							  "source":""
							  }
										
																						
										 ]';

                EXEC dbo.SpOptionNewTsk @Json = @Json;

            END;

            COMMIT TRANSACTION;

        END TRY
        BEGIN CATCH
            IF ( @@TRANCOUNT > 0 )
                SELECT 'a';
            ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;























GO
