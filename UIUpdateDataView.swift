//
//  UIUpdateDataView.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/19/21.
//

import Foundation
import UIKit

class UIUpdateDataView: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var ethnicity: UITextField!
    @IBOutlet weak var height: UITextField!
    @IBOutlet weak var waist: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var weight: UITextField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = UserManager.shared.getUser()
        //Loading current users data into text fields
        addDataToTextFields()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        
    }
    
    private func addDataToTextFields() {
        guard let _user = user else {
            let alert = UIAlertController(title: "Error!", message: "Something Went wrong :(", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        firstName.text = _user.firstName
        lastName.text = _user.lastName
        ethnicity.text = _user.ethnicity
        height.text = String(_user.height)
        waist.text = String(_user.waistSize)
        age.text = String(_user.age)
        weight.text = String(_user.weight)
        email.text = _user.email
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "sleepTime"{
            if(email.text == "" || firstName.text == "" || lastName.text == "" || age.text == "" || ethnicity.text == "" || height.text == "" || weight.text == "" ||
                Int(age.text!) == nil || Int(height.text!) == nil || Int(waist.text!) == nil || Int(weight.text!) == nil){
                let alert = UIAlertController(title: "Incomplete", message: "Please enter all fields", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sleepTime"{
            let age = Int(age.text!)!
            let ethnicity = ethnicity.text!
            let height = Int(height.text!)!
            let waistsize = Int(waist.text!)!
            let weight = Int(weight.text!)!
            
            let user = User(email: email.text ?? "", password: user?.password ?? "", firstName: firstName.text ?? "", lastName: lastName.text ?? "", gender: user?.gender ?? 0, ethnicity: ethnicity, age: age, height: height, waistSize: waistsize, weight: weight)
            
            UserManager.shared.loginUser(user: user)
        }
    }
}
