//
//  SleepGraphViewController.swift
//  OxygenSaturation


import UIKit
import Charts
import RealmSwift

class SleepGraphViewController: UIViewController {
  
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var lineChart: LineChartView!
    
    let realm = try! Realm()
    
    var sleepData: [SleepAnalysisRealm] = [] {
        //didset is called whenever sleepdata receives values
        didSet{
            lineChart.data = formLineChartData()
            lineChart.leftAxis.axisMinimum = -10
            //lineChart.leftAxis.axisMaximum = 100
            
        }
    }

    
    var startDate: Date?
    var endDate: Date?
    
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
        // Do any additional setup after loading the view.
        pieChartUpdate()

    }
    
    func getSleepData() {
        let data = realm.objects(SleepAnalysisRealm.self)
        sleepData = data.filter({ val in
            ((val.date ?? Date()) > (self.startDate ?? Date())) && ((val.date ?? Date()) < self.endDate ?? Date())
        }).sorted(by: { val1, val2 in
            (val1.date ?? Date()) < (val2.date ?? Date())
        })
        
    }
    
    //repeat for 2nd set
    func formLineChartData() -> LineChartData {
        let chartEntries = sleepData.enumerated().map { (offset, element) -> ChartDataEntry in
            return ChartDataEntry(x: Double(offset) , y: element.delta)
        }
        
        lineChart.rightAxis.enabled = false
        
        let chartData = LineChartDataSet(entries: chartEntries)
        chartData.drawCirclesEnabled = false
        chartData.mode = .horizontalBezier
        chartData.lineWidth = 3
        
        let data = LineChartData(dataSet: chartData)
        
        data.setDrawValues(false)
        
        let deepSleepLine = ChartLimitLine(limit: 2)
        deepSleepLine.lineColor = UIColor.blue.withAlphaComponent(0.6)
        deepSleepLine.lineWidth = 1
        lineChart.leftAxis.addLimitLine(deepSleepLine)
        
        let lightSleepLine = ChartLimitLine(limit: 4)
        lightSleepLine.lineColor = UIColor.green.withAlphaComponent(0.6)
        
        let remSleepLine = ChartLimitLine(limit: 10)
        remSleepLine.lineColor = UIColor.purple.withAlphaComponent(0.6)
        
        let awakeLine = ChartLimitLine(limit: 15)
        awakeLine.lineColor = UIColor.yellow.withAlphaComponent(0.6)

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
        
        sleepData.forEach { val in
            datesRecorded.append(getDateInStr(date: val.date ?? Date()))
        }
        
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: datesRecorded)
        
        return data
    }
    func pieChartUpdate() -> PieChartData{
        let entry1 = PieChartDataEntry(value: 1.1, label: "Light Sleep")
        let entry2 = PieChartDataEntry(value: 2.1, label: "Deep Sleep")
        let entry3 = PieChartDataEntry(value: 3.1, label: "Rem Sleep")
        let entry4 = PieChartDataEntry(value: 4.1, label: "Awake")
        let dataSet = PieChartDataSet(entries: [entry1, entry2, entry3, entry4], label: "Sleep")
        let pieData = PieChartData(dataSet: dataSet)
        pieChart.data = pieData
 
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.valueColors = [UIColor.black]
        pieChart.backgroundColor = UIColor.white
        pieChart.holeColor = UIColor.clear
        pieChart.chartDescription?.textColor = UIColor.black
        pieChart.legend.textColor = UIColor.black
        pieChart.legend.font = UIFont(name: "Futura", size: 10)!
        pieChart.chartDescription?.font = UIFont(name: "Futura", size: 12)!
        pieChart.chartDescription?.xOffset = pieChart.frame.width + 30
        pieChart.chartDescription?.yOffset = pieChart.frame.height * (2/3)
        pieChart.chartDescription?.textAlign = NSTextAlignment.left
        
        pieChart.notifyDataSetChanged()
        return pieData

    }

    
    private func getDateInStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        let date = dateFormatter.string(from: date)
        return " " + date + " "
    }
}
