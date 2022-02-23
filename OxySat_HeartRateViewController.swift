//
//  OxySat_HeartRateViewController.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 22/11/2021.



import UIKit
import Charts
import RealmSwift

class OxySat_HeartRateViewController: UIViewController {
  
    
    @IBOutlet weak var lineChart: LineChartView!
    
    let realm = try! Realm()
    
    var oxySatData: [OxygenSaturation] = []
    
    var HeartRateData: [HeartRate] = [] {
        //didset is called whenever sleepdata receives values
        didSet{
            DispatchQueue.main.async {[self] in
                lineChart.data = formLineChartData()
                lineChart.leftAxis.axisMinimum = -10
            }
        }
    }

    
    var startDate: Date!
    var endDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let start_time = try? UserDefaults.standard.getObject(forKey: "sleepStart", castTo: Date.self),
              let end_time = try? UserDefaults.standard.getObject(forKey: "sleepEnd", castTo: Date.self)
        else { return }
        let sleepTimings = Helper.getSleepStartAndEndForToday(sleepStart: start_time, sleepEnd: end_time)
        startDate = sleepTimings.0
        endDate = sleepTimings.1
        
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        
        getSleepData()
    }
    
    func getSleepData() {
        HealthKitManager.shared.getHeartRate(startDate: startDate, endDate: endDate) {[weak self] val, err in
            guard let hr = val, let _ = self else { return }
            if let _ = err { return }
            
            HealthKitManager.shared.getOxySaturation(startDate: self!.startDate, endDate: self!.endDate) {[weak self] val, err in
                guard let oS = val, let _ = self else { return }
                if let _ = err { return }
                self!.oxySatData = oS
                self!.HeartRateData = hr.filter({ val in
                    val.dateRecorded >= self!.startDate && val.dateRecorded <= self!.endDate
                }).sorted(by: { val1, val2 in
                    val1.dateRecorded < val2.dateRecorded
                })
            }
            
            
        }
        
    }
    
    //repeat for 2nd set
    func formLineChartData() -> LineChartData {
        let chartEntries = HeartRateData.enumerated().map { (offset, element) -> ChartDataEntry in
            return ChartDataEntry(x: Double(offset) , y: element.countsPerMin)
        }
        
        lineChart.rightAxis.enabled = true
        
        let chartData = LineChartDataSet(entries: chartEntries)
        chartData.drawCirclesEnabled = false
        chartData.mode = .horizontalBezier
        chartData.lineWidth = 2
        chartData.setColor(UIColor.green.withAlphaComponent(0.5))
        chartData.label = "Heart Rate"
        
        var counter = 0
        let chartEntries2 = HeartRateData.enumerated().map { (offset, element) -> ChartDataEntry in
            if(counter>=oxySatData.count){
                return ChartDataEntry(x: Double(offset) , y: oxySatData[oxySatData.count-1].level*100)
            }
            
            if(oxySatData[counter].dateRecorded>element.dateRecorded) {
                return ChartDataEntry(x: Double(offset) , y: oxySatData[counter].level*100)
            } else{
                counter = counter+1 >= oxySatData.count ? counter : counter+1
                return ChartDataEntry(x: Double(offset) , y: oxySatData[counter].level*100)
            }
            
        }
        
        lineChart.rightAxis.enabled = true
        
        let chartData2 = LineChartDataSet(entries: chartEntries2)
        chartData2.drawCirclesEnabled = false
        chartData2.mode = .horizontalBezier
        chartData2.lineWidth = 2
        chartData2.setColor(UIColor.red.withAlphaComponent(0.5))
        chartData2.label = "Oxygen Saturation"
        
        let data = LineChartData(dataSets: [chartData,chartData2])
        
        //data.setDrawValues(false)

//        let maxLimitLine = ChartLimitLine(limit: 40)
//        maxLimitLine.lineColor = UIColor.red.withAlphaComponent(0.6)
//        maxLimitLine.lineWidth = 1
//        lineChart.leftAxis.addLimitLine(maxLimitLine)
//
//        let minLimitLine = ChartLimitLine(limit: 10)
//        minLimitLine.lineColor =  UIColor.systemGreen.withAlphaComponent(0.6)
//        minLimitLine.lineWidth = 1
//        lineChart.leftAxis.addLimitLine(minLimitLine)
//
//        let zeroLimitLine = ChartLimitLine(limit: 0)
//        zeroLimitLine.lineColor =  UIColor.black.withAlphaComponent(0.6)
//        zeroLimitLine.lineWidth = 1
//        lineChart.leftAxis.addLimitLine(zeroLimitLine)
       
        var datesRecorded:[String] = []
        
        HeartRateData.forEach { val in
            datesRecorded.append(getDateInStr(date: val.dateRecorded))
        }
        
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: datesRecorded)
        
        return data
    }
    
    private func getDateInStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        let date = dateFormatter.string(from: date)
        return " " + date + " "
    }
}
