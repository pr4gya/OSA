//
//  HealthKitManager.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 8/1/21.
//
import HealthKit
import Foundation

class HealthKitManager{
    
    //shared creates an instance of the class, must be done within the class you want to call into others
    static let shared = HealthKitManager()
    
    var timer: Timer? = nil
    var lastDateFetched: Date? = nil
    
    init(){
        //init for private singleton class
    }
        
    let healthStore = HKHealthStore()
    let quantitiesInUse = [HKObjectType.quantityType(forIdentifier: .heartRate)!,
                           HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                           HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
    
    
    func areAllQuantitiedAuthorized() -> Bool{
    
        for quantityType in quantitiesInUse {
            let status = healthStore.authorizationStatus(for: quantityType)
            if status == .notDetermined || status == .sharingDenied{
                return false
            }
        }
        return true
    }
    
    func requestAuthorization(){
        
        
        let quantities = Set(quantitiesInUse)
        healthStore.requestAuthorization(toShare: quantities, read: quantities) { didApprove, error in
        
        }
    }
    
    //MARK: Function(s) for getting HeartRate Data from healthKit
    func getHeartRate(startDate: Date, endDate: Date, completion: (([HeartRate]?,Error?)->())? ) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion?(nil,nil)
            return
        }
        
        //predicate is a foundation describing how data will be sampled/filtered
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate ,options: .strictStartDate)
        
        //sorts values by ascending value
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
            if let err = error{
                completion?(nil,err)
                return
            }
            var resultToReturn: [HeartRate] = []
            let heartRateUnit = HKUnit(from: "count/min")
            result?.forEach({ sample in
                let data = sample as! HKQuantitySample
                let countsPerMin = data.quantity.doubleValue(for: heartRateUnit)
                let dateRecorded = data.endDate
               
                let heartRate = HeartRate(countsPerMin: countsPerMin, dateRecorded: dateRecorded)
                resultToReturn.append(heartRate)
                
            })
            
            completion?(resultToReturn,nil)
        }
        
        healthStore.execute(query)
    }
    
    func getHeartRate(for duration: Timeline = .Month, completion: (([HeartRate]?,Error?)->())? ) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion?(nil,nil)
            return
        }
        var startDate: Date? = nil
    
        if duration == .Day {
            startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        } else if duration == .Month {
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        } else {
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        }
        
        //predicate is a foundation describing how data will be sampled/filtered
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        //sorts values by ascending value
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
            if let err = error{
                completion?(nil,err)
                return
            }
            var resultToReturn: [HeartRate] = []
            let heartRateUnit = HKUnit(from: "count/min")
            result?.forEach({ sample in
                let data = sample as! HKQuantitySample
                let countsPerMin = data.quantity.doubleValue(for: heartRateUnit)
                let dateRecorded = data.endDate
               
                let heartRate = HeartRate(countsPerMin: countsPerMin, dateRecorded: dateRecorded)
                resultToReturn.append(heartRate)
                
            })
            
            completion?(resultToReturn,nil)
        }
        
        healthStore.execute(query)
    }
    
    ///This function gets the acg heart rate between the start time and end time
    private func getAvgHRForDay(startTime: Date, endTime: Date, completion: ((Double?,Error?)->())?){
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion?(nil,nil)
            return
        }
        
        //specify the interval between readings, in this case it is the difference between start time and end time
        let dateComponents = NSDateComponents()
        let components = Calendar.current.dateComponents([.hour,.minute], from: startTime, to: endTime)
        dateComponents.hour = components.hour ?? 14
        dateComponents.minute = components.minute ?? 0
        
        //health kit query for getting avg
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .discreteAverage, anchorDate: startTime , intervalComponents: dateComponents as DateComponents )
        
        //This function is called on result
        query.initialResultsHandler = { (sample, result, error) in
            
            //check for error
            if let err = error{
                completion?(nil,err)
                return
            }
           
            let heartRateUnit = HKUnit(from: "count/min")
            //Get the days Avg Heart Rate
            result?.enumerateStatistics(from: startTime, to: startTime, with: { stats, stop in
                
                //check to make sure that value is not nil -> if not check to make sure that the statistic value is between the interval that is asked for
                if let quantity = stats.averageQuantity(), stats.startDate >= startTime && stats.endDate <= endTime {
                    let value = quantity.doubleValue(for: heartRateUnit)
                    completion?(value, nil)
                } else {
                    completion?(nil, nil)
                }
                return
            })
        }
        
        healthStore.execute(query)
        
    }
    ///numberOfDaysInPastToAnalyse takes a value for the number of days in the past the analysis is to be done.
    func getAverageHR(numberOfDaysInPastToAnalyse days: Int = 5, sleepStartTime: Date, sleepEndTime: Date ,completion: ((Double?,Error?)->())?){
        
        //Dispatch Group has been used to write asynchronous code. Computation for the values can take time, so inorder for the code to keep running
        let dispatchGroup = DispatchGroup()
        
        //Calculate current Day,Month,Year
        let todaysDay = Calendar.current.component(Calendar.Component.day, from: Date())
        let todaysMonth = Calendar.current.component(Calendar.Component.month, from: Date())
        let todaysYear = Calendar.current.component(Calendar.Component.year, from: Date())
        
        //Calculate the hours and minutes between sleepEnd time and sleepStart time -> Time the user is awake
        let awakeTimeComponents = Calendar.current.dateComponents([.hour,.minute], from: sleepEndTime, to: sleepStartTime)
        
        //hh and ss components for the sleep end time -> 09, 30
        let sleepEndTimeComponents = Calendar.current.dateComponents([.hour,.minute], from: sleepEndTime)
        //Calculate the sleep end time for today with the help of sleepEndTimeComponents and todaysDay, todaysMonth , todaysYear  -> 09,30 will become 09:30, 10th September
        let sleepEndTimeToday = Calendar.current.date(from: DateComponents(timeZone: .current, year: todaysYear, month: todaysMonth, day: todaysDay, hour: sleepEndTimeComponents.hour, minute: sleepEndTimeComponents.minute))
        
        //Avg heart rate to start will be nil to start -> loop will nun for number of days in the past the analysis is to be done. The value is initially nil as there could be no readings available
        //numberOfMeasurements will count the number of days there was an average reading
        var totalAvgHeartRate: Double? = nil
        var numberOfMeasurements = 0
        for i in 0..<days {
            // calculating the sleep end time -> sleep start time for i number of days in the past.
            guard let _sleepEndTimeToday = sleepEndTimeToday,
                  let startTime = Calendar.current.date(byAdding: .day, value: -i, to: _sleepEndTimeToday),
                  let awakeHrs = awakeTimeComponents.hour,
                  let awakeMins = awakeTimeComponents.minute,
                  let endTime_temp = Calendar.current.date(byAdding: .hour, value: abs(awakeHrs) , to: startTime),
                  let endTime = Calendar.current.date(byAdding: .minute, value: abs(awakeMins) , to: endTime_temp)
                  else { return }
            
            dispatchGroup.enter()
            
            //get geart rate reading for i days in the past
            getAvgHRForDay(startTime: startTime, endTime: endTime) { val, err in
                //check if value was nil, if not add to totalAvgHeartRate and increment numberOfMeasurements by 1
                if let v = val {
                    totalAvgHeartRate = totalAvgHeartRate == nil ? v : totalAvgHeartRate! + v
                    numberOfMeasurements+=1
                }
                dispatchGroup.leave()
            }
        }
        
        //After the loop has run and all the values are calculated , inform the caller of the function for calculated avg
        dispatchGroup.notify(queue: .global(qos: .userInteractive)) {
            if let avgHR = totalAvgHeartRate {
                completion?(avgHR/Double(numberOfMeasurements),nil)
            } else {
                completion?(nil,nil)
            }
        }
    }
    
   
    //MARK: Function(s) for getting Oxygen Saturation Data from healthKit
    func getOxySaturation(startDate: Date, endDate: Date, completion: (([OxygenSaturation]?,Error?)->())?) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
            completion?(nil,nil)
            return
        }
 
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { sample, result, error in
            if let err = error{
                completion?(nil,err)
                return
            }
            var resultToReturn: [OxygenSaturation] = []
            let bloodOxyUnit = HKUnit(from: "%")
            result?.forEach({ sample in
                let data = sample as! HKQuantitySample
                let percent = data.quantity.doubleValue(for: bloodOxyUnit)
                let dateRecorded = data.endDate
                
                let bloodoxygen = OxygenSaturation(level: percent, dateRecorded: dateRecorded)
                resultToReturn.append(bloodoxygen)
                
            })
            
            completion?(resultToReturn,nil)
        }
        
        healthStore.execute(query)
    }
    
    func getOxySaturation(for duration: Timeline = .Month, completion: (([OxygenSaturation]?,Error?)->())?) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
            completion?(nil,nil)
            return
        }
        
        //>
        var startDate: Date? = nil
        
        if duration == .Day {
            startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        } else if duration == .Month {
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        } else {
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        }
        
        //>
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { sample, result, error in
            if let err = error{
                completion?(nil,err)
                return
            }
            var resultToReturn: [OxygenSaturation] = []
            let bloodOxyUnit = HKUnit(from: "%")
            result?.forEach({ sample in
                let data = sample as! HKQuantitySample
                let percent = data.quantity.doubleValue(for: bloodOxyUnit)
                let dateRecorded = data.endDate
                
                let bloodoxygen = OxygenSaturation(level: percent, dateRecorded: dateRecorded)
                resultToReturn.append(bloodoxygen)
                
            })
            
            completion?(resultToReturn,nil)
        }
        
        healthStore.execute(query)
    }
    
    private func getOxySaturation(for startDate: Date, completion: (([OxygenSaturation]?,Error?)->())?) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
            completion?(nil,nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { sample, result, error in
            if let err = error{
                completion?(nil,err)
                return
            }
            var resultToReturn: [OxygenSaturation] = []
            let bloodOxyUnit = HKUnit(from: "%")
            result?.forEach({ sample in
                let data = sample as! HKQuantitySample
                let percent = data.quantity.doubleValue(for: bloodOxyUnit)
                let dateRecorded = data.endDate
                
                let bloodoxygen = OxygenSaturation(level: percent, dateRecorded: dateRecorded)
                resultToReturn.append(bloodoxygen)
                
            })
            
            completion?(resultToReturn,nil)
        }
        
        healthStore.execute(query)
    }
    
    func startOxygenSaturationUpdates(timeIntervalInSeconds: Int) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeIntervalInSeconds), target: self, selector: #selector(getLatestOxygenSaturationValues), userInfo: nil, repeats: true)
    }
    
    func stopOxygenSaturationUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func getLatestOxygenSaturationValues(){
        guard let lastDate = lastDateFetched else {
            lastDateFetched = Date()
            return
        }
        getOxySaturation(for: lastDate) { oxySat, err in
            if err != nil || oxySat == nil {
                print(err ?? "ERROR fetching oxysat values!!!")
                return
            }
            
            //Below 85
            //Below 90
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NEW_OXY_SAT_VALUE"), object: nil, userInfo: ["Data": oxySat!])
        }
        
    }
    
    //MARK: Function(s) for getting Sleep Data from healthKit
    func getSleepData(for duration: Timeline = .Month, completion: (([Sleep]?,Error?)->())?) {
        guard let quantityType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion?(nil,nil)
            return
        }
        
        var startDate: Date? = nil
        
        if duration == .Day {
            startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        } else if duration == .Month {
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        } else {
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { sample, result, error in
            if let err = error{
                completion?(nil,err)
                return
            }
            var resultToReturn: [Sleep] = []
            result?.forEach({ sample in
                let data = sample as! HKCategorySample
                let inBed = data.value == HKCategoryValueSleepAnalysis.inBed.rawValue ? true : false
                
                let sleep = Sleep(startTime: data.startDate, endTime: data.endDate, inBed: inBed)
                resultToReturn.append(sleep)
                
            })
            
            completion?(resultToReturn,nil)
        }
        
        healthStore.execute(query)
    }
    
}
    
enum Timeline{
    case Day, Week, Month, Year
}

