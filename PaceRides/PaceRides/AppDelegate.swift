//
//  AppDelegate.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

enum TransitionDestination {
    case organization(String)
    case event(String)
}

enum UserDefaultsKeys: String {
    case EULAAgreementSeconds = "EULAAgreementSeconds"
}

enum DataDBKeys: String {
    case data = "data"
    case eula = "eula"
    case author = "author"
}

enum EULADBKeys: String {
    case text = "text"
    case timestamp = "timestamp"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var transitionDestination: TransitionDestination? = nil
    
    override init() {
        super.init()
        
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        Auth.auth().addStateDidChangeListener(UserModel.firebaseAuthStateChangeListener)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance()!.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "launchscreen") as! LaunchScreenViewController
        self.window?.rootViewController = viewcontroller
        self.window?.makeKeyAndVisible()
        viewcontroller.activityIndicator.isHidden = false
        viewcontroller.activityIndicator.startAnimating()
        
        let eulaAgreementSeconds
            = UserDefaults.standard.object(forKey: UserDefaultsKeys.EULAAgreementSeconds.rawValue) as? NSNumber
        
        if let eulaAgreementSeconds = eulaAgreementSeconds, eulaAgreementSeconds.int64Value > 0 {
            
            Firestore.firestore().collection(DataDBKeys.data.rawValue)
                .document(DataDBKeys.eula.rawValue).getDocument() { document, error in
                    
                    // TODO: Handle errors
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    guard let data = document?.data() else {
                        print("No data in eula")
                        return
                    }
                    
                    guard let eulaTimestamp = data[EULADBKeys.timestamp.rawValue] as? Timestamp else {
                        print("No eula text")
                        return
                    }
                    
                    if eulaAgreementSeconds.int64Value > eulaTimestamp.seconds {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "RevealVC")
                        self.window?.rootViewController = viewcontroller
                        self.window?.makeKeyAndVisible()
                    } else {
                        self.displayEULAViewController()
                    }
            }
        } else {
            self.displayEULAViewController()
        }
        
        return true
    }
    
    private func displayEULAViewController() {
        
        let eulaRef = Firestore.firestore().collection(DataDBKeys.data.rawValue).document(DataDBKeys.eula.rawValue)
        eulaRef.getDocument() { document, error in
            
            // TODO: Handle errors
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = document?.data() else {
                print("No data in eula")
                return
            }
            
            guard let eulaText = data[EULADBKeys.text.rawValue] as? String else {
                print("No eula text")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewcontroller = storyboard.instantiateViewController(withIdentifier: "EULAViewController") as! EULAViewController
            viewcontroller.eulaText = eulaText
            self.window?.rootViewController = viewcontroller
            self.window?.makeKeyAndVisible()
            
        }
        
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance()!.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return handled
    }
    
    
    private func queryParameters(from url: URL) -> [String: String] {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryParams = [String: String]()
        for queryItem: URLQueryItem in (urlComponents?.queryItems)! {
            if queryItem.value == nil {
                continue
            }
            queryParams[queryItem.name] = queryItem.value
        }
        return queryParams
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                
                guard let host = url.host, host.lowercased() == "pacerides.com" else {
                    return true
                }
                
                if url.path.lowercased().contains("organization"), let orgId = queryParameters(from: url)["id"] {
                    self.transitionDestination = TransitionDestination.organization(orgId)
                }
                
                if url.path.lowercased().contains("event"), let eventId = queryParameters(from: url)["id"] {
                    self.transitionDestination = TransitionDestination.event(eventId)
                }
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let revealVC = mainStoryboard.instantiateViewController(withIdentifier: "RevealVC")
                self.window?.rootViewController = revealVC
                self.window?.makeKeyAndVisible()
            }
        }
        
        return true
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
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

