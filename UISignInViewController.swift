//
//  UISignInViewController.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/2/21.
//

import UIKit
var storyBoard: UIStoryboard!

class UISignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        storyBoard = UIStoryboard(name:"Main", bundle: nil)
        if UserDefaults.standard.bool(forKey: "login"){
//            let demo = storyBoard.instantiateViewController(identifier: "Demo")
//            self.navigationController?.
            let tabBar = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "Demo")
          
                UIApplication.shared.windows.first?.rootViewController = tabBar
        }

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func Login(_ sender: UIButton) {
        
        let tabBar = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "Demo")
            UIApplication.shared.windows.first?.rootViewController = tabBar
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

class VC: UIViewController{
    override func viewDidLoad(){
        super.viewDidLoad()
    }
}
