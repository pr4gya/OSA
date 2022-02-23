//
//  ViewController.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 6/14/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("CoreData path :: \(self.getCoreDataDBPath())")
        print("test")
        // Do any additional setup after loading the view.
    }
    func getCoreDataDBPath() {
            let path = FileManager
                .default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .last?
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
                .removingPercentEncoding

            print("Core Data DB Path :: \(path ?? "Not found")")
        }
    
    func createUserData() {
        //singleton class for coredata vars
        //obj of appdelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //obj of viewcontext from appdelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        
        //obj of entity from CoreDataTests.xc
        let entityUser = NSEntityDescription.entity(forEntityName: "User", in: viewContext)
    
        //obj for the entity created above^ used to put data into entity
        let user = NSManagedObject(entity: entityUser!, insertInto: viewContext)
            //insert values in database
            user.setValue("password", forKey: "password")
            user.setValue("pragya@gmail.com", forKey: "email")
//            user.setValue("female", forKey:"true")
            user.setValue(16, forKey:"age")
            
        do {
            try viewContext.save()
        } catch {
            print("Database insertion failed")
        }
    }
}
