//
//  AccelerometerAnalysisManager.swift
//  OxygenSaturation WatchKit Extension
//
//  Created by Pragya Prakash on 8/13/2021.
//

import WatchKit
import Foundation
import AVFoundation

class AccelerometerAnalysisManager {
    
    var player: AVAudioPlayer?
    
    static let shared = AccelerometerAnalysisManager()
    
    var shaker = WatchShaker(shakeSensibility: .shakeSensitivityNormal, delay: 0.0)
    
    var values: [AccelerometerValue] = []
    
    var maxValueRecorded = 1.0
    
    var dateMaxValueRecorded = Date()
    
    var windowSizeInMinutes = 3
    
    private init() {
        //singleton
        //Initializer will start listening to updates from watch shaker
        shaker.start()
        shaker.startWatchShakerUpdates = { shakeSensibility, coordinates, direction ,error in
            self.watchShakerDidUpdate(coordinates: coordinates, direction: direction, error: error)
        }
    }
    
    ///Function called from watch shaker class when new coordinate is registered.
    func watchShakerDidUpdate( coordinates: ShakeCoordinates?, direction: ShakeDirection? ,error: Error?) {
        guard error == nil else
        {
            print(error!.localizedDescription)
            return
        }
        
        //null check
        guard let coordinates = coordinates else {
            return
        }
        
        //Get maximum acceleration direction
        let x = abs(coordinates.x)
        let y = abs(coordinates.y)
        let z = abs(coordinates.z)
        var maxValue = (x > y ? x : y) > z ? (x > y ? x : y) : z
        //Scale maximum values by dividing by 2
        maxValue = maxValue/2
        //value less than 1 will registered, 1 will be the minimum value, only values above 1 will be considered.
        if maxValue <= 1 {
            return
        }
        //Store the maximum value recorded by comparing to previous max value -> maxValueRecorded
        maxValueRecorded = max(maxValue,maxValueRecorded)
    
    }
    
    ///Function called from Sleep Analysis Manager, registers the maximum value since the last time this function was called -> Calculates caximim value in the 3 minute window interval -> resets the maximum value -> Returns the max value
    func getMaxValueInWindow() -> AccelerometerValue? {
        //Register New Value
        let accelerometerValue = AccelerometerValue(value: maxValueRecorded, date: Date())
        maxValueRecorded = 1
        values.append(accelerometerValue)
        
        //Set upper limit(-> now), lower limit(-> now - 3 mins)
        let upperLimit = Date()
        guard let lowerLimit = Calendar.current.date(byAdding: .minute, value: -windowSizeInMinutes, to: Date())  else {
            return nil
        }
        
        //Filter values in between upper limit and lower limit times
        values = values.filter({ value in
            (value.date < upperLimit) && (value.date > lowerLimit)
        })
        
        //Get max value and return 
        let value = values.max { val1, val2 in
            val1.value<val2.value
        }
        return value
    }
    
    
    
    
    //MARK:- OLD CODE
    
    var numberOfTimesUserAlerted = 0
    
    var accelerationThreshold: Double = 3.0 // decreasing value leads to higher sensitivity
    
    var thresholdCrossedLimit: Double = 2.0 // How long in seconds the threshold can be crossed for
    
    var ThresholdCrossLimit: Double = 3.0 // Number of times in thresholdCrossedLimit the threshold can be crossed
    
    var thresholdCrossedTimes: [Date] = []
    
    func watchShakerDidUpdate(shakeSensibility: ShakeSensibility?, coordinates: ShakeCoordinates?, direction: ShakeDirection? ,error: Error?) {
        guard error == nil else
        {
            print(error!.localizedDescription)
            return
        }
        
        //null check
        guard let coordinates = coordinates else {
            return
        }
        
        //Get maximum acceleration direction
        let maxValue = (coordinates.x > coordinates.y ? coordinates.x : coordinates.y) > coordinates.z ? (coordinates.x > coordinates.y ? coordinates.x : coordinates.y) : coordinates.z
        
        
        if maxValue > accelerationThreshold {
            //Acc. threshold crossed
            self.thresholdCrossed(at: Date())
        }
        print(maxValue)
    }


    func thresholdCrossed(at time: Date) {
        //Keep record of each time threshold was crossed
        self.thresholdCrossedTimes.append(time)

        //Filerting out values in from last "thresholdCrossedTimes" "thresholdCrossedLimit" seconds
        thresholdCrossedTimes = self.thresholdCrossedTimes.filter { time in
            let differenceInSeconds = abs(Calendar.current.dateComponents([.second], from: time, to: Date()).second ?? 0)
            return Double(differenceInSeconds) < Double(self.thresholdCrossedLimit)
        }
        
        if Double(thresholdCrossedTimes.count) > ThresholdCrossLimit {
            thresholdCrossedTimes = []
            playHaptics(numberOfTimes: 10)
            playSound()
            numberOfTimesUserAlerted+=1
            
        }
        
    }
    
    func playHaptics(numberOfTimes: Int) {
        if numberOfTimes <= 0 {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //
            WKInterfaceDevice.current().play(.failure)
            self.playHaptics(numberOfTimes: numberOfTimes-1)
        }
    }
    
    func playSound() {
        if let path = Bundle.main.path(forResource: "alert", ofType: "mp3") {
            
            let fileUrl = URL(fileURLWithPath: path)
            
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                player = try AVAudioPlayer(contentsOf: fileUrl)
                
                guard let player = player else { return }
                
                player.play()
                
            }
            catch
            {
                print(error)
            }
            
        }
    }

}

struct AccelerometerValue {
    let value: Double
    let date: Date
}
