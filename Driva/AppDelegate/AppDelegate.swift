//
//  AppDelegate.swift
//  Driva
//
//  Created by mediatrenz on 20/07/18.
//  Copyright © 2018 mediatrenz. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import UserNotifications
import SlideMenuControllerSwift
import IQKeyboardManagerSwift
import GooglePlaces

import Firebase
import RNNotificationView

let kGCMMessageIDKey = "gcm.message_id"
let GoogleApiKey = "AIzaSyCV614nsASuF55bciGgV1Dke6cYxTeqfIQ"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        GMSServices.provideAPIKey(GoogleApiKey)
        GMSPlacesClient.provideAPIKey(GoogleApiKey)

        
        // Restart any tasks that were paused (or
        self.loadMenu()

        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications(completionHandler: { (notificationRequests) in
            for x in notificationRequests {
                let userInfo = x.request.content.userInfo
                
                // Print message ID.
                if let messageID = userInfo[kGCMMessageIDKey] {
                    //            print("Message ID: \(messageID)")
                }
                
                // Print full message.
                //        print(userInfo)
                
                if (userInfo["gcm.notification.type"] as! String == "ride_accepted") {
                    NotificationCenter.default.post(name: Notification.Name("acceptNotification"), object: nil, userInfo: userInfo)
                } else if (userInfo["gcm.notification.type"] as! String == "ride_canceled"){
                    NotificationCenter.default.post(name: Notification.Name("cancelNotification"), object: nil, userInfo: userInfo)
                }else if (userInfo["gcm.notification.type"] as! String == "ride_finish"){
                    NotificationCenter.default.post(name: Notification.Name("finishNotification"), object: nil, userInfo: userInfo)
                }else if (userInfo["gcm.notification.type"] as! String == "ride_start"){
                    NotificationCenter.default.post(name: Notification.Name("startNotification"), object: nil, userInfo: userInfo)
                }else if (userInfo["gcm.notification.type"] as! String == "delete"){
                    _ = UserDetail.shared.setUserLogin(false)
                 
                }
                
            }
        })
        
        center.removeAllDeliveredNotifications()
        
        self.loadLoginView()
        // Fire Configure
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        requestNotificationAuthorization(application: application)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //Handle background notification
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] {
            FCMNotification().didTapOnNotifications(with: userInfo as! [String : Any])
        }
        
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        UserDefaults.standard.setDeviceID(value: deviceID)

        return true
    }
    
    func loadMenuView() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
        let navigationController = UINavigationController(rootViewController: rootViewController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    func loadLoginView() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let navigationController = UINavigationController(rootViewController: rootViewController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    public func loadMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
            as! ViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        leftViewController.BookYourRideVC = nvc
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        self.window?.rootViewController = slideMenuController
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        var viewSplash = UIView(frame: CGRect(x: 0, y: 0, width: (self.window?.frame.size.width)!, height: (self.window?.frame.size.height)!))
        viewSplash.backgroundColor = UIColor.white
        var splashScreen = UIImageView(image: UIImage(named: "LaunchIcon"))
        splashScreen.center = viewSplash.center
        
        viewSplash.addSubview(splashScreen)
        
        self.window?.addSubview(viewSplash)
        self.window?.bringSubview(toFront: viewSplash) //!
        
        Timer.scheduledTimer(withTimeInterval: 8, repeats: false) { (timer) in
            viewSplash.removeFromSuperview()
        }
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications(completionHandler: { (notificationRequests) in
            for x in notificationRequests {
                let userInfo = x.request.content.userInfo
                
                // Print message ID.
                if let messageID = userInfo[kGCMMessageIDKey] {
                    //            print("Message ID: \(messageID)")
                }
                
                // Print full message.
                //        print(userInfo)
                
                if (userInfo["gcm.notification.type"] as! String == "ride_accepted") {
                    NotificationCenter.default.post(name: Notification.Name("acceptNotification"), object: nil, userInfo: userInfo)
                } else if (userInfo["gcm.notification.type"] as! String == "ride_canceled"){
                    NotificationCenter.default.post(name: Notification.Name("cancelNotification"), object: nil, userInfo: userInfo)
                }else if (userInfo["gcm.notification.type"] as! String == "ride_finish"){
                    NotificationCenter.default.post(name: Notification.Name("finishNotification"), object: nil, userInfo: userInfo)
                }else if (userInfo["gcm.notification.type"] as! String == "ride_start"){
                    NotificationCenter.default.post(name: Notification.Name("startNotification"), object: nil, userInfo: userInfo)
                }else if (userInfo["gcm.notification.type"] as! String == "delete"){
                    _ = UserDetail.shared.setUserLogin(false)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    let navigationController = UINavigationController(rootViewController: rootViewController)
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                }
                
            }
        })
        
        center.removeAllDeliveredNotifications()
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Driva")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func handleNotification(dataDict: NSDictionary) {
//        print(dataDict)
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
//        print("Device Token: \(token)")
        
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        UserDefaults.standard.setDeviceID(value: deviceID)

    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

}
