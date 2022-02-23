//
//  HeartRateCell.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 18/11/2021.
//

import UIKit

class HeartRateCell: UITableViewCell {

    @IBOutlet weak var minHeartRate: UILabel!
    @IBOutlet weak var maxHeartRate: UILabel!
    @IBOutlet weak var avgHeartRate: UILabel!
    @IBOutlet weak var viewDetailsButton: UIButton!
    
    var sleepStartTime: Date!
    var sleepEndTime: Date!
    var callback: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func detailsViewPressed(_ sender: Any) {
        callback?()
    }
    
    func apply() {
        guard let sleepStart = try? UserDefaults.standard.getObject(forKey: "sleepStart", castTo: Date.self),
              let sleepEnd = try? UserDefaults.standard.getObject(forKey: "sleepEnd", castTo: Date.self) else {
                  maxHeartRate.isHidden = true
                  avgHeartRate.isHidden = true
                  minHeartRate.isHidden = false
                  viewDetailsButton.isHidden = true
                  minHeartRate.text = "The sleep data will be available after sleep timing"
                  return
              }
        

        self.setupUI(_sleepStart: sleepStart, _sleepEnd: sleepEnd)
    }
    
    private func setupUI(_sleepStart: Date, _sleepEnd: Date){
        let todaysSleepTimings = Helper.getSleepStartAndEndForToday(sleepStart: _sleepStart, sleepEnd: _sleepEnd)
        sleepStartTime = todaysSleepTimings.0
        sleepEndTime = todaysSleepTimings.1
        
        if sleepEndTime > Date() {
            maxHeartRate.isHidden = true
            avgHeartRate.isHidden = true
            minHeartRate.isHidden = false
            viewDetailsButton.isHidden = true
            minHeartRate.text = "The sleep data will be available after sleep timing"
            return
        }
        
        HealthKitManager.shared.getAverageHR(sleepStartTime: sleepStartTime, sleepEndTime: sleepEndTime) { [weak self] avgHr, err in
            DispatchQueue.main.async {
                self?.avgHeartRate.text = "Avg: \(Int(avgHr ?? 0))"
            }
            
        }
        HealthKitManager.shared.getHeartRate(startDate: sleepStartTime, endDate: sleepEndTime) { [weak self] heartRates, err in
            guard let hr = heartRates else { return }
            if let _ = err {return}
            var min = Int.max
            var max = Int.min
            DispatchQueue.global(qos: .userInitiated).async {
                hr.forEach({ val in
                    min = min < Int(val.countsPerMin) ? min : Int(val.countsPerMin)
                    max = max > Int(val.countsPerMin) ? max : Int(val.countsPerMin)
                })
                
                DispatchQueue.main.async {
                    self?.minHeartRate.text = "Min: \(min)"
                    self?.maxHeartRate.text = "Max: \(max)"
                }
            }
        }
        
        
    }
    
}
