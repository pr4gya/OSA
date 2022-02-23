//
//  UIReportView.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/19/21.
//

import UIKit
import RealmSwift
import Lottie

class UIReportView: UIViewController{
    
    @IBOutlet weak var topBarButton: BadgeBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var lottieView: UIView!
    
    let realm = try! Realm()
    var alertView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        nameLabel.text = "Hi, \(UserManager.shared.getUser()?.firstName ?? "")"
        
        if !HealthKitManager.shared.areAllQuantitiedAuthorized(){
            HealthKitManager.shared.requestAuthorization()
        }
        
        tableView.register(UINib(nibName: "LastNightSleep", bundle: nil), forCellReuseIdentifier: "LastNightSleep")
        tableView.register(UINib(nibName: "HeartRateCell", bundle: nil), forCellReuseIdentifier: "HeartRateCell")
        tableView.register(UINib(nibName: "OxygenSaturationCell", bundle: nil), forCellReuseIdentifier: "OxygenSaturationCell")
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setBadges() {
        if let _ = try? UserDefaults.standard.getObject(forKey: "sleepStart", castTo: Date.self),
           let _ = try? UserDefaults.standard.getObject(forKey: "sleepEnd", castTo: Date.self){
            topBarButton.badgeNumber = 0
        } else {
            topBarButton.badgeNumber = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBadges()
        
        let data = realm.objects(SleepAnalysisRealm.self)
        
        let lastRecordedSleepDate = data.max(by: { val1, val2 in
            val1.date!<val2.date!
        })
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM-dd-yyyy HH:mm:ss"
        if let date = lastRecordedSleepDate?.date {
           // label.text = "Last recorded time - \(dateFormatterGet.string(from: date ))"
        } else {
            //label.text = "No data found"
        }
        if !((UIApplication.shared.delegate as! AppDelegate).watchSession?.isReachable ?? false) {
            UIView.animate(withDuration: 0.5) {
                self.warningView.isHidden = false
            }
            setupAnimationView()
        } else {
            UIView.animate(withDuration: 0.5) { [self] in
                warningView.isHidden = true
            }
        }
        
        
//        if let data = try? UserDefaults.standard.getObject(forKey: "min_max_hr_arr", castTo: [SleepAnalysis].self){
//
//            let lastRecordedSleepDate = data.max(by: { val1, val2 in
//                val1.date<val2.date
//            })
//            let dateFormatterGet = DateFormatter()
//            dateFormatterGet.dateFormat = "MMM-dd-yyyy HH:mm:ss"
//            label.text = "Last recorded time - \(dateFormatterGet.string(from: lastRecordedSleepDate!.date))"
//        }
    }
    private func setupAnimationView() {
        alertView = AnimationView()
         
        alertView!.frame = lottieView.bounds
        alertView.animation = Animation.named("warning")
         //Set animation content mode
         
        alertView!.contentMode = .scaleAspectFit
         
         //Set animation loop mode
         
        alertView!.loopMode = .loop
         
         //Adjust animation speed
         
        alertView!.animationSpeed = 0.5
         
        lottieView.addSubview(alertView)
         
         //Play animation
         
        alertView!.play()
    }
    
    private func openSleepGraphController() {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "SleepGraphViewController") as! SleepGraphViewController
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    
    private func openHeartRateAndOxySatGraphController() {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "OxySat_HeartRateViewController") as! OxySat_HeartRateViewController
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    
}

extension UIReportView: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = nil
        
        switch indexPath.row {
        case 0:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "LastNightSleep") as! LastNightSleep
            (cell as! LastNightSleep).apply()
            (cell as! LastNightSleep).detailsButtonPressed = {[weak self] in
                self?.openSleepGraphController()
            }
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "HeartRateCell") as! HeartRateCell
            (cell as! HeartRateCell).apply()
            (cell as! HeartRateCell).callback = { [weak self] in
                self?.openHeartRateAndOxySatGraphController()
            }
        case 2:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "OxygenSaturationCell") as! OxygenSaturationCell
            (cell as! OxygenSaturationCell).apply()
            (cell as! OxygenSaturationCell).callback = { [weak self] in
                self?.openHeartRateAndOxySatGraphController()
            }
            
            
        default:
            return UITableViewCell()
        }
        

        return cell
    }
}
