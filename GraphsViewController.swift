//
//  UIGraphView.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/19/21.
//

import UIKit
import Charts

class GraphsViewController: ViewController, ChartViewDelegate{
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var heartRates: [HeartRate] = []
    var oxygenSaturations: [OxygenSaturation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = 1
        getHeartRateDataAndUpdate(timeLine: .Month)
        
    }
    
    
    @IBAction func timelineChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            getHeartRateDataAndUpdate(timeLine: .Day)
        case 1:
            getHeartRateDataAndUpdate(timeLine: .Month)
        case 2:
            getHeartRateDataAndUpdate(timeLine: .Year)
        default:
            return
        }
    }
    
    private func getHeartRateDataAndUpdate(timeLine: Timeline){
        HealthKitManager.shared.getHeartRate(for: timeLine){
            result, error in
            //completion handler
            guard error == nil, let res = result, !res.isEmpty else{return}
            self.updateChartData(withHeartRateValues: res)
        }
    }
    
    func updateChartData(withHeartRateValues heartRate: [HeartRate]) {
        //wrapping UI updates on main queue
        DispatchQueue.main.async {
            self.heartRates = heartRate
            self.lineChart.data = self.formLineChartData(heartRateData: heartRate)
          
            self.setupChartView()
            self.lineChart.moveViewToX(self.lineChart.chartXMax)
        }
    }
    
    func updateO2Data(withO2DataValues bloodoxygen: [OxygenSaturation]){
        DispatchQueue.main.async {
        self.oxygenSaturations = bloodoxygen
        self.lineChart.data = self.formO2Data(bloodOxyData: bloodoxygen)
        self.setupChartView()
        self.lineChart.moveViewToX(self.lineChart.chartXMax)

        }
    }
    
    func formLineChartData(heartRateData: [HeartRate]) -> LineChartData {
        let chartEntries = heartRateData.enumerated().map { (offset, element) -> ChartDataEntry in
            return ChartDataEntry(x: Double(offset) , y: element.countsPerMin)
        }
        let chartData = LineChartDataSet(entries: chartEntries, label: "HeartRate")
//        let chartData = LineChartDataSet(entries: chartEntries)
        chartData.mode = .horizontalBezier
        ///Chart UI adjustment
        chartData.setCircleColor(UIColor.white.withAlphaComponent(0.5))
        chartData.circleHoleColor = .white
        chartData.circleHoleRadius = 7
        chartData.lineWidth = 1
        chartData.setColor(.white)
        chartData.circleRadius = 10
        chartData.lineWidth = 3
        chartData.drawFilledEnabled = true
        
        // Colors of the gradient
        let gradientColors = [UIColor.white.cgColor,
                              UIColor.white.withAlphaComponent(0.5).cgColor,
                              UIColor.clear.cgColor] as CFArray
        
        let colorLocations:[CGFloat] = [0.8, 0.3 ,0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        chartData.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        chartData.drawFilledEnabled = true // Draw the Gradient
        
        // font for Heart rate on top
        let data = LineChartData(dataSet: chartData)
        data.setValueTextColor(.black)
        data.setValueFont(.boldSystemFont(ofSize: 12))
        
        var datesRecorded:[String] = []
        
        heartRates.forEach { hr in
            datesRecorded.append(getDateInStr(date: hr.dateRecorded ?? Date()))
        }
        
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: datesRecorded)
        lineChart.xAxis.granularity = 1
        return data
    }
    
    func formO2Data(bloodOxyData: [OxygenSaturation]) -> LineChartData {
        let chartEntries = bloodOxyData.enumerated().map { (offset, element) -> ChartDataEntry in
            return ChartDataEntry(x: Double(offset) , y: element.level)
        }
        let chartData = LineChartDataSet(entries: chartEntries)
        chartData.mode = .horizontalBezier
        
        ///Chart UI adjustment
        chartData.setCircleColor(UIColor.red.withAlphaComponent(0.5))
        chartData.circleHoleColor = .red
        chartData.circleHoleRadius = 7
        chartData.lineWidth = 1
        chartData.setColor(.red)
        chartData.circleRadius = 10
        chartData.lineWidth = 3
        chartData.drawFilledEnabled = true
        
        // Colors of the gradient
        let gradientColors = [UIColor.white.cgColor,
                              UIColor.white.withAlphaComponent(0.5).cgColor,
                              UIColor.clear.cgColor] as CFArray
        
        let colorLocations:[CGFloat] = [0.8, 0.3 ,0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        chartData.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        chartData.drawFilledEnabled = true // Draw the Gradient
        
        // font for Heart rate on top
        let data = LineChartData(dataSet: chartData)
        data.setValueTextColor(.black)
        data.setValueFont(.boldSystemFont(ofSize: 12))
        
        var datesRecorded:[String] = []
        
        oxygenSaturations.forEach { bloodoxygen in
            datesRecorded.append(getDateInStr(date: bloodoxygen.dateRecorded ?? Date()))
        }
        
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: datesRecorded)
        lineChart.xAxis.granularity = 1
        return data
    }
    
    func setupChartView() {
        lineChart.delegate = self
        lineChart.data?.setValueFormatter(self)
        lineChart.setVisibleXRangeMaximum(5)
        lineChart.drawBordersEnabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.rightAxis.enabled = false
    
        lineChart.leftAxis.drawLimitLinesBehindDataEnabled = true
        lineChart.leftAxis.axisLineColor = .white
        lineChart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChart.leftAxis.gridColor = .white
        lineChart.chartAnimator.animate(xAxisDuration: 0.5)
        
            // Graph XAxis config
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.gridColor = .white
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        lineChart.setDragOffsetX(10)
        lineChart.xAxis.spaceMin = 1
        lineChart.xAxis.spaceMax = 0.5

        lineChart.highlightPerTapEnabled = false
        lineChart.highlightPerDragEnabled = false
        
        lineChart.legend.enabled = false
    
        lineChart.backgroundColor = #colorLiteral(red: 0.477422297, green: 0.5996902585, blue: 1, alpha: 1)
        
    }
    
    //Helper function to convert Date() into String in format of MM d,HH:mm
    private func getDateInStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d,HH:mm"
        let date = dateFormatter.string(from: date)
        return date
    }

}

extension GraphsViewController: IValueFormatter {
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        
        return String(Int(heartRates[Int(entry.x)].countsPerMin))
        return String(Int(oxygenSaturations[Int(entry.x)].level))

    }
}

