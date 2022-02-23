//
//  UIRegistration2ViewController.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/2/21.
//

import UIKit

class UIRegistration2ViewController: UIViewController {
    
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var ethnicityTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var waistsizeTF: UITextField!
    @IBOutlet weak var weightTf: UITextField!
    
    var email: String!
    var password: String!
    var fName: String!
    var lName: String!
    var gender: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    

    @IBAction func checkFields(_ sender: UIButton) {
        if(ageTF.text == "" || ethnicityTF.text == "" || heightTF.text == "" || waistsizeTF.text == "" ||
            Int(ageTF.text!) == nil || Int(heightTF.text!) == nil || Int(waistsizeTF.text!) == nil || Int(weightTf.text!) == nil){
            
            let alert = UIAlertController(title: "Incomplete", message: "Fields are incomplete or incorrect", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
        else{
            let age = Int(ageTF.text!)!
            let ethnicity = ethnicityTF.text!
            let height = Int(heightTF.text!)!
            let waistsize = Int(waistsizeTF.text!)!
            let weight = Int(weightTf.text!)!

            let user = User(email: email, password: password, firstName: fName, lastName: lName, gender: gender, ethnicity: ethnicity, age: age, height: height, waistSize: waistsize, weight: weight)
            
            UserManager.shared.loginUser(user: user)
            
            let tabBar = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "Demo")
          
                UIApplication.shared.windows.first?.rootViewController = tabBar
                
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
