//
//  CombinedGraphViews.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 9/11/21.
//

import Foundation
import Charts

class CombinedGraphView: ViewController{
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var desiredIntervals: UISegmentedControl!
    
    override func viewDidLoad() {
        
        lineChartUpdate()
        pieChartUpdate()
        
    }
    
    
    
    
    func lineChartUpdate(){
        let entry1 = BarChartDataEntry(x: 1.0, y: 2)
        let entry2 = BarChartDataEntry(x: 2.0, y: 4)
        let entry3 = BarChartDataEntry(x: 3.0, y: 6)
        LineChartDataSet(entries: [entry1, entry2, entry3], label: "Ok")
       
        lineChart.notifyDataSetChanged()

    }
    
    func pieChartUpdate(){
        
        pieChart.notifyDataSetChanged()
    }
}
