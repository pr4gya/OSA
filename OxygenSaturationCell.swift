//
//  OxygenSaturationCell.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 22/11/2021.
//

import UIKit

class OxygenSaturationCell: UITableViewCell {
    
    @IBOutlet weak var minOS: UILabel!
    @IBOutlet weak var maxOS: UILabel!
    @IBOutlet weak var avgOS: UILabel!
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
                  maxOS.isHidden = true
                  avgOS.isHidden = true
                  minOS.isHidden = false
                  viewDetailsButton.isHidden = true
                  minOS.text = "The sleep data will be available after sleep timing"
                  return
              }
        

        self.setupUI(_sleepStart: sleepStart, _sleepEnd: sleepEnd)
    }
    
    private func setupUI(_sleepStart: Date, _sleepEnd: Date){
        let todaysSleepTimings = Helper.getSleepStartAndEndForToday(sleepStart: _sleepStart, sleepEnd: _sleepEnd)
        sleepStartTime = todaysSleepTimings.0
        sleepEndTime = todaysSleepTimings.1
        
        if sleepEndTime > Date() {
            maxOS.isHidden = true
            avgOS.isHidden = true
            minOS.isHidden = false
            viewDetailsButton.isHidden = true
            minOS.text = "The sleep data will be available after sleep timing"
            return
        }
        
        HealthKitManager.shared.getOxySaturation(startDate: sleepStartTime, endDate: sleepEndTime) { [weak self] vals, err in
            guard let oS = vals else { return }
            if let _ = err {return}
            var min = Int.max
            var max = Int.min
            var sum = 0
            DispatchQueue.global(qos: .userInitiated).async {
                oS.forEach({ val in
                    min = min < Int(val.level*100) ? min : Int(val.level*100)
                    max = max > Int(val.level*100) ? max : Int(val.level*100)
                    sum += Int(val.level*100)
                })
                
                DispatchQueue.main.async {
                    self?.minOS.text = "Min: \(min)"
                    self?.maxOS.text = "Max: \(max)"
                    self?.avgOS.text = "Avg: \(sum/oS.count)"
                }
            }
        }
        
        
    }
    
}
