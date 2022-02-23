//
//  YourHealthView.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 8/1/21.
//

import UIKit
import HealthKit

class YourHealthViewController: ViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKit()
    }
    
    func authorizeHealthKit(){
        let userDidApprove = HealthKitManager.shared.areAllQuantitiedAuthorized()
        if userDidApprove == false{
            HealthKitManager.shared.requestAuthorization()
        }
    }
    @IBAction func _viewGraphPressed(_sender: Any){
        let graphsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "GraphsViewController")
        self.navigationController?.pushViewController(graphsVC, animated: true)
    }
}
