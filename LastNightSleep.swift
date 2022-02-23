//
//  LastNightSleep.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 11/11/2021.
//

import UIKit

class LastNightSleep: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lastNightSleep: UILabel!
    @IBOutlet weak var targetSleepTime: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    
    var sleepStartTime: Date?
    var sleepEndTime: Date?
    var hKSleepData: Sleep?
    
    var detailsButtonPressed: (()->())?
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.layer.cornerRadius = 10
    }
    
    func apply(){
        HealthKitManager.shared.getSleepData(for: .Day) {[weak self] res, err in
            self?.sleepStartTime = try? UserDefaults.standard.getObject(forKey: "sleepStart", castTo: Date.self)
            self?.sleepEndTime = try? UserDefaults.standard.getObject(forKey: "sleepEnd", castTo: Date.self)
            self?.hKSleepData = res?.first
            DispatchQueue.main.async {
                self?.setUpUI()
            }
        }
        
    }
    
    @IBAction func detailsButtonPressed(_ sender: Any) {
        detailsButtonPressed?()
    }
    
    private func setUpUI(){
        guard var sleepStart = sleepStartTime,
              var sleepEnd = sleepEndTime,
              let _hkSleep = hKSleepData else{
                  lastNightSleep.text = "No sleep data available"
                  targetSleepTime.isHidden = true
                  detailsButton.isHidden = true
                  return
              }
        let todaysDay = Calendar.current.component(.day, from: Date())
        let todaysMonth = Calendar.current.component(.month, from: Date())
        let todaysYear = Calendar.current.component(.year, from: Date())
        let sleepEndHour = Calendar.current.component(.hour, from: sleepEnd)
        let sleepEndMin = Calendar.current.component(.minute, from: sleepEnd)
        sleepEnd = Calendar.current.date(from: DateComponents(year: todaysYear, month: todaysMonth, day: todaysDay, hour: sleepEndHour, minute: sleepEndMin)) ?? Date()
        
        if sleepEnd > Date() {
            lastNightSleep.text = "Sleep Analysis will be available after sleep timing"
            targetSleepTime.isHidden = true
            detailsButton.isHidden = true
            return
        }
        
        let timeSlept = Helper.numberOfHoursBetween(_hkSleep.startTime, and: _hkSleep.endTime)
        
        lastNightSleep.text = "You slept for \(timeSlept.0) hours and \(timeSlept.1) minutes last night \n between \(Helper.formatDate(date: _hkSleep.startTime)) and \(Helper.formatDate(date: _hkSleep.endTime))"
        targetSleepTime.isHidden = false
        detailsButton.isHidden = false
        targetSleepTime.text = "Your target sleep time was \(Helper.formatDate(date: sleepStart)) and \(Helper.formatDate(date: sleepEnd))"
        
        
    }
    
}
