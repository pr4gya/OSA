//
//  UIRegistrationViewController.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/2/21.
//

import UIKit

class UIRegistrationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //text fields
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var fNameTF: UITextField!
    @IBOutlet weak var lNameTF: UITextField!
    //swipe field
    @IBOutlet weak var genderSF: UISegmentedControl!
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Registration2"{
            if(emailTF.text == "" || passwordTF.text == "" || fNameTF.text == "" || lNameTF.text == ""){
                let alert = UIAlertController(title: "Incomplete", message: "Please enter all fields", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Registration2"{
            
            let registration2VC = segue.destination as! UIRegistration2ViewController
            
            let email = emailTF.text
            let password = passwordTF.text
            let fName = fNameTF.text
            let lName = lNameTF.text
            let gender = genderSF.selectedSegmentIndex // 0 = female

            registration2VC.email = email
            registration2VC.password = password
            registration2VC.fName = fName
            registration2VC.lName = lName
            registration2VC.gender = gender
        }
    }

}
