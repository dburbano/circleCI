//
//  AppDelegate.swift
//  machApp
//
//  Created by lukas burns on 2/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import UserNotifications
import Swinject
import RealmSwift
import DropDown
import Branch
import Alamofire
import Firebase

#if STAGING
    import HockeySDK
#endif
#if DEBUG || AUTOMATION
    import HockeySDK
#endif
#if RELEASE
    import Fabric
    import Crashlytics
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let navigationController = UINavigationController()

    lazy var passcodeManager: PasscodeManager = {
        let presenter = PasscodeManager(mainWindow: self.window)
        return presenter
    }()
    //swiftlint:disable:next force_unwrapping
    lazy var reachabilityManager: NetworkReachabilityManager = NetworkReachabilityManager()!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always

        self.initializeNewRelic()
        self.initializeBranchIO(with: launchOptions)
        self.initializeHockeyApp()
        self.initializeFabric()
        self.initializeFirebase()
        self.initializeZendesk()
        self.initializeAnalytics()
        self.initializeSiftScience()
        startReachabilityListener()

        self.executeRealmMigration()
        Container.loggingFunction = nil

        if AccountManager.sharedInstance.isLoggedIn() {
            let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
            APISecurityManager.sharedInstance.createCipherKeyIfNotPresent(shouldForceCreate: false)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
            self.window?.rootViewController = rootViewController
            self.passcodeManager.presentPasscode()
            NotificationManager.sharedInstance.startListeningForMessages()
            ContactManager.sharedInstance.sendPhoneContacts()
            if let machId = AccountManager.sharedInstance.getMachId() {
                SiftScienceManager.sharedInstance.setUserId(userId: machId)
            }
        } else if AccountManager.sharedInstance.isAccountCreationInProcess() {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let createAccountViewController = mainStoryboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController {
                let navigationController = UINavigationController()
                navigationController.navigationBar.isHidden = true
                navigationController.viewControllers = [createAccountViewController]
                self.window?.rootViewController = navigationController
            }
        } else {
            ConfigurationManager.sharedInstance.switchToContingencyModeIfServersNotResponding()
        }

        self.window?.makeKeyAndVisible()

        window?.backgroundColor = UIColor.white

        print("My Mach Id is: \(String(describing: AccountManager.sharedInstance.getMachId())) ?? None")

        Theme.applyTheme()

        DropDown.startListeningToKeyboard()

        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: .UserLoggedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userBlackListed), name: .UserBlackListed, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(contactStoreDidChange), name: .CNContactStoreDidChange, object: nil)

        return true
    }
    
    func checkForContingencyStatus() {
        
    }

    @objc func contactStoreDidChange(notification: NSNotification) {
        ContactManager.sharedInstance.syncContacts()
    }

    func startReachabilityListener() {
        reachabilityManager.startListening()
        reachabilityManager.listener = {[weak self] status in
            if let unwrappedSelf = self {
                print("Network Status Changed: \(status)")
                print("\(unwrappedSelf.reachabilityManager.isReachable)")
            }
        }
    }

    func initializeNewRelic() {
        #if DEBUG || AUTOMATION
            NewRelic.start(withApplicationToken: "AA01d8e711a27be4a94d73eb2a01aa1102147e96f0")
        #endif

        #if STAGING
            NewRelic.start(withApplicationToken: "AA56469d154d7629d68fd4b3415196f7c00fa4d050")
        #endif

        #if RELEASE
            NewRelic.start(withApplicationToken: "AAf8e2937dfc976f4a5bbe7ca34bae3d78a4ed96f2")
        #endif

    }

    func initializeHockeyApp() {
        #if STAGING
            BITHockeyManager.shared().configure(withIdentifier: "2fd8f6f875fd4119955b4b886c7c32bc")
            BITHockeyManager.shared().start()
            BITHockeyManager.shared().authenticator.authenticateInstallation()
        #endif

        #if DEBUG
            BITHockeyManager.shared().configure(withIdentifier: "f81aa95b361a46df969926fc41bf5a93")
            BITHockeyManager.shared().logLevel = .none
            BITHockeyManager.shared().start()
            BITHockeyManager.shared().authenticator.authenticateInstallation()
        #endif
        
        #if AUTOMATION
            BITHockeyManager.shared().configure(withIdentifier: "107b7ef5f5074d9a889afb4d832d1ae1")
            BITHockeyManager.shared().logLevel = .none
            BITHockeyManager.shared().start()
            BITHockeyManager.shared().authenticator.authenticateInstallation()
        #endif
    }

    func initializeFabric() {
        #if RELEASE
            Fabric.with([Crashlytics.self])
        #endif
    }
    
    func initializeFirebase() {
        FirebaseApp.configure()
    }

    func initializeBranchIO(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        #if DEBUG || STAGING || AUTOMATION
            Branch.setUseTestBranchKey(true)
        #endif

        Branch.getInstance().initSession(launchOptions: launchOptions) { params, _ in
            print(params as? [String: AnyObject] ?? {})
            if let params = params, let deeplink = params["deepLink"] as? String, let url = URL.init(string: deeplink) {
                deepLinker.handleDeepLink(url: url)
                deepLinker.checkDeepLink()
            }
        }
    }

    func initializeZendesk() {
        // ZendeskManager.sharedInstance.start()
    }

    func initializeSiftScience() {
        SiftScienceManager.sharedInstance.start()
    }

    func initializeAnalytics() {
        SegmentManager.sharedInstance.start()
    }

    func executeRealmMigration() {
        RealmManager.executeMigration()
    }

    @objc func userLoggedOut() {
        self.passcodeManager.dismissPasscode()
        AccountManager.sharedInstance.performLogOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RegisterNavigationViewController")
        self.window?.rootViewController = rootViewController
    }

    @objc func userBlackListed() {
        let storyboard = UIStoryboard(name: "BlackListed", bundle: nil)
        let blackListedViewController = storyboard.instantiateViewController(withIdentifier: "BlackListedViewController")
        let navigationController = UINavigationController(rootViewController: blackListedViewController)
        navigationController.navBar?.isHidden = true
        self.window?.rootViewController = navigationController
        AccountManager.sharedInstance.performLogOut()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /* Sent when the application is about to move from active to inactive state. 
           This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
           or when the user quits the application and it begins the transition to the background state.
           Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
           Games should use this method to pause the game.
         */

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        /* Use this method to release shared resources, save user data, invalidate timers,
           and store enough application state information to restore your application to its current state in case it is terminated later.
           If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        */
        NotificationCenter.default.post(name: .ApplicationDidEnterBackground, object: nil)
        self.passcodeManager.presentPasscode()
        reachabilityManager.stopListening()
        NotificationManager.sharedInstance.stop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        /* Called as part of the transition from the background to the active state;
           here you can undo many of the changes made on entering the background.
        */
        if AccountManager.sharedInstance.isLoggedIn() {

            NotificationManager.sharedInstance.startListeningForMessages()
        }
        self.passcodeManager.presentPasscode()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        /* Restart any tasks that were paused (or not yet started) while the application was inactive.
           If the application was previously in the background, optionally refresh the user interface.
        */
        if AccountManager.sharedInstance.isLoggedIn() {
            AccountManager.sharedInstance.fetchAndUpdateUser()
            NotificationManager.sharedInstance.startListeningForMessages()
        }
        //Every time the application opens, unless it is in foreground, it triggers this method
        deepLinker.checkDeepLink()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - Push Notifications

extension AppDelegate {

    func registerForPushNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: options) { (granted, _) in
                // Enable or disable features based on authorization.
                if granted {
                    DispatchQueue.main.async(execute: {
                        application.registerForRemoteNotifications()
                    })
                }
            center.delegate = self
            }
        } else {
            // Fallback on earlier versions ios < 1.0
            let type: UIUserNotificationType = [.alert, .badge, .sound]
            let notificationSettings = UIUserNotificationSettings(types: type, categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
            application.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("Device Token \(deviceToken.description)")
        let manager = APNManager()
        manager.performAPNTokenRegistration(tokenDevice: deviceToken)
    }

    // For ios < 10.0
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) { }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //This is the case when the app  is in foreground
        if application.applicationState == .active {
            //Handle push notification. Maybe show an alert or something and then trigger deepLinker.handleRemoteNotification(userInfo) & deepLinker.checkDeepLink()
        } else {
            deepLinker.handleRemoteNotification(userInfo)
            deepLinker.checkDeepLink()
        }
        completionHandler(.noData)
    }

    // MARK: Branch.io
    // Respond to URI scheme links
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let sourceApplicationOptions = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String else { return false }
        
        // pass the url to the handle deep link call
        let branchHandled = Branch.getInstance().application(app,
                                                             open: url,
                                                             sourceApplication: sourceApplicationOptions,
                                                             annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        if !branchHandled {
            //Universal link handle.
            let handled = deepLinker.handleDeepLink(url: url)
            deepLinker.checkDeepLink()
            return handled
        }

        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        return true
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {

    // Foreground push notificaitons handler.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let userInfo = notification.request.content.userInfo as? [String: AnyObject] {
            print(userInfo)
        }
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String: AnyObject] {
            //This is the case when the app  is in foreground
            deepLinker.handleRemoteNotification(userInfo)
            deepLinker.checkDeepLink()
        }
        completionHandler()
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}
