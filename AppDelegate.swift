//
//  AppDelegate.swift
//  CoreDataTests
//
//  Created by Pragya Prakash on 6/20/21.
//
import IQKeyboardManagerSwift
import UIKit
import CoreData
import WatchConnectivity
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var watchSession: WCSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        watchSession = WCSession.default
        watchSession?.delegate = self
        watchSession?.activate()
        IQKeyboardManager.shared.enable = true
        // Override point for customization after application launch.
        return true
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        
        //holds database
        //contains table and attributes, must know how to create obj and call
        let container = NSPersistentContainer(name: "CoreDataTests")
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

    // MARK: - Core Data Saving support

    func saveContext () {
        //middle layer of core data where operations are executed(crud)
        //function to update
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

}

//MARK:- Connection to Watch

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //Error Handling
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //Error Handling
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //Error Handling
    }
    
    // Function called when new data from watch is received
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        //decode the Json response from watch
        if let sleepData = try? decoder.decode(SleepAnalysis.self, from: messageData) {

            saveDataToRealm(sleepData: sleepData)
            
            //reply to watch that data is received successfully
            replyHandler(try! encoder.encode(true))
        } else if let query = try? decoder.decode(String.self, from: messageData), query == "GET_AVG_HEART_RATE"{
            
            //If else statements are just for null checks 
            if let sleepStartTime = try? UserDefaults.standard.getObject(forKey: "sleepStart", castTo: Date.self),
               let sleepEndTime = try? UserDefaults.standard.getObject(forKey: "sleepEnd", castTo: Date.self) {
                
                HealthKitManager.shared.getAverageHR(sleepStartTime: sleepStartTime, sleepEndTime: sleepEndTime) { avgHr, err in
                    if err != nil || avgHr == nil {
                        replyHandler(Data())
                    } else {
                        replyHandler(try! encoder.encode(avgHr))
                    }
                }
                
            } else {
                replyHandler(Data())
            }
            
        } else {
            //reply to watch that data is not received successfully
            replyHandler(try! encoder.encode(false))
        }
    }

    //This function saves the data to realm
    func saveDataToRealm(sleepData: SleepAnalysis) {
        
        ///When writing values continously Realm needs to run on the same thread(as this function is called multiple times in quick succession in some cases ), hence a specific thread is defined
        let backgroundQueue = DispatchQueue(label: "com.app.queue",
                                            qos: .background,
                                            target: nil)
        ///Mapping to realmObjects
        let minHeartRateRealm = HeartRateRealm(countsPerMin: sleepData.min.countsPerMin, dateRecorded: sleepData.min.dateRecorded)
        let maxHeartRateRealm = HeartRateRealm(countsPerMin: sleepData.max.countsPerMin, dateRecorded: sleepData.max.dateRecorded)
        let realmObject = SleepAnalysisRealm(min: minHeartRateRealm, max: maxHeartRateRealm, maxAccelerometerCount: sleepData.maxAccelerometerCount, date: sleepData.date)
        ///saving to realm on thread defined above
        backgroundQueue.async {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(realmObject)
            try! realm.commitWrite()
        }
    }
}

