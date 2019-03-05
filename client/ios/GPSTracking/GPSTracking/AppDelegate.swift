//
//  AppDelegate.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var deviceToken: NSData?
    var window: UIWindow?
    var locationTracker: DLLocationTracker?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        ServerCountly.sharedInstance.provider()

        RegisterSliderPhotosFormViewCell()
        RegisterColorFormViewCell()
        RegisterAreaFormViewCell()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        if launchOptions?[UIApplicationLaunchOptionsLocationKey] != nil {
            let locationTracker = DLLocationTracker()
            self.locationTracker = locationTracker
            
            locationTracker.locationUpdatedInBackground = {(location) in
                //отправляем на сервер
                ServerCheckin.sharedInstance.checkin(location)
//                let notification = UILocalNotification()
//                notification.fireDate = NSDate(timeIntervalSinceNow: 15)
//                notification.alertBody = NSString(format: "New location %@", location) as String
//                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
            
            locationTracker.startUpdatingLocation()
        }
        
        if #available(iOS 9.0, *) {
            self.registerShorcutItems(application)
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if application.applicationIconBadgeNumber != 0 {
            application.applicationIconBadgeNumber = 0
        }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        application.applicationIconBadgeNumber = 1;
        application.applicationIconBadgeNumber = 0;
    }

    func applicationWillTerminate(application: UIApplication) {

    }
    
    //--------------
    let NotificationCategoryIdent:String    = "ACTION_INTERACTIVE"
    let NotificationActionOneIdent:String   = "ACTION_ONE"
    let NotificationActionTwoIdent:String   = "ACTION_TWO"
    
    func registerForNotification() {
        let action1:UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        action1.activationMode = UIUserNotificationActivationMode.Foreground
        action1.title = "Подробнее"
        action1.identifier = NotificationActionOneIdent
        action1.destructive = false
        action1.authenticationRequired = false
        
        let action3:UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        action3.activationMode = UIUserNotificationActivationMode.Background
        action3.title = "Отклонить"
        action3.identifier = NotificationActionTwoIdent
        action3.destructive = true
        action3.authenticationRequired = false
        
        let actionCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = NotificationCategoryIdent
        actionCategory.setActions([action3, action1], forContext: UIUserNotificationActionContext.Default)
        
        let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes:
            [   UIUserNotificationType.Alert,
                UIUserNotificationType.Sound,
                UIUserNotificationType.Badge
            ], categories: NSSet(object: actionCategory) as? Set<UIUserNotificationCategory>)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        if(identifier == NotificationActionOneIdent) {
            //ответить
            ApnHelper.handleRemoteNotification(userInfo)
        } else if(identifier == NotificationActionTwoIdent) {
            //отклонить
            //отправить запрос
        }
        
        completionHandler()
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        completionHandler(true)
    }
    
    
    @available(iOS 9.0, *)
    func registerShorcutItems(application: UIApplication) {
            // Override point for customization after application launch.
        let shortcut1 = UIMutableApplicationShortcutItem(type: "0", localizedTitle: "Создать запрос",
            localizedSubtitle: "Создать запрос",
            icon: UIApplicationShortcutIcon(type: .Add),
            userInfo:nil
        )

        // Update the application providing the initial 'dynamic' shortcut items.
        application.shortcutItems = [shortcut1]
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSLog("Did receiveLocalNotification:%@", notification)
        //пришло событие изменени местоположения
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.deviceToken = deviceToken
        ApnHelper.registerDevice(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        //background handler
        
        ApnHelper.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        ServerCountly.sharedInstance.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //получение нотификации
        
    }
    
    func sendNotification() {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = "Pull down to interact."
        notification.category = "ACTION_INTERACTIVE"
        notification.fireDate = NSDate(timeIntervalSinceNow: 10)
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

