//
//  DatePickerViewController.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 8/17/21.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var sleepStartDatePicker: UIDatePicker!
    @IBOutlet weak var sleepEndDatePicker: UIDatePicker!
    @IBOutlet weak var informationText: UILabel!
    
    
    var sleepStart = Date()
    var sleepEnd = Date()
    
//    let sleepStart = Calendar.current.date
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        
    }
    
    private func initializeUI() {
        initializeDatePickers()
        UpdateInformationLabel()
    }
    
    private func initializeDatePickers() {
        guard
            let start_time = try? UserDefaults.standard.getObject(forKey: "sleepStart", castTo: Date.self),
            let end_time = try? UserDefaults.standard.getObject(forKey: "sleepEnd", castTo: Date.self)
        else { return }
        sleepStartDatePicker.date = start_time
        sleepEndDatePicker.date = end_time
        
    }
    
    private func UpdateInformationLabel() {
        if let start_time = try? UserDefaults.standard.getObject(forKey: "sleepStart", castTo: Date.self),
           let end_time = try? UserDefaults.standard.getObject(forKey: "sleepEnd", castTo: Date.self) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let sleepStartFormatted = dateFormatter.string(from: start_time)
            let sleepEndFormatted = dateFormatter.string(from: end_time)
            let diff = calculateTimeDifferenceBetween(date1: start_time, date2: end_time)
            
            let normalFont = UIFont.systemFont(ofSize: 16)
            let boldFont = UIFont.boldSystemFont(ofSize: 16)
            let string = "Your sleep time is between \(sleepStartFormatted) to \(sleepEndFormatted) ~ \(diff) hours of sleep"
            informationText.attributedText = addBoldText(fullString: string as NSString, boldPartsOfString: ["\(sleepStartFormatted)","\(sleepEndFormatted)","\(diff) hours"] as [NSString], font: normalFont, boldFont: boldFont)
            
        } else {
            informationText.text = "Please set your sleep timing!"
        }
    }

    @IBAction func getSleepStart(_ sender: UIDatePicker) {
        sleepStart = sender.date
        //added try bc this function can throw an error
        print(sleepStart)
        try? UserDefaults.standard.setObject(sleepStart, forKey: "sleepStart")
        UserDefaults.standard.synchronize()
        formatDate()
        UpdateInformationLabel()
    }
    
    @IBAction func getSleepEnd(_ sender: UIDatePicker) {
        sleepEnd = sender.date
        try? UserDefaults.standard.setObject(sleepEnd, forKey: "sleepEnd")
        UserDefaults.standard.synchronize()
        formatDate()
        UpdateInformationLabel()
    }
    
    func formatDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        let sleepEndFormatted = dateFormatter.string(from: sleepEnd)
        let sleepEnd = dateFormatter.date(from: sleepEndFormatted)
        
        let sleepStartFormatted = dateFormatter.string(from: sleepStart)
        let sleepStart = dateFormatter.date(from: sleepStartFormatted)
//        let sleepEndF = formatter.date(from: sleepEnd(String))
        try? UserDefaults.standard.setObject(sleepEnd, forKey: "sleepEndString")
        try? UserDefaults.standard.setObject(sleepStart, forKey: "sleepStartString")
        UserDefaults.standard.synchronize()

    }
    
    private func calculateTimeDifferenceBetween(date1:Date, date2:Date)-> (Int){

        let comp1 = Calendar.current.dateComponents([.hour,.minute], from: date1)
        let comp2 = Calendar.current.dateComponents([.hour,.minute], from: date2)
        
        var hours = 0
        if let comp1Hr = comp1.hour, let comp2Hr = comp2.hour {
            if comp1Hr > comp2Hr {
                hours = (24 - comp1Hr) + (comp2Hr)
            }else {
                hours = (comp2.hour ?? 0) - (comp1.hour ?? 0)
            }
        }
       
        return (abs(hours))
    }

    private func addBoldText(fullString: NSString, boldPartsOfString: Array<NSString>, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font!]
        let boldFontAttribute: [NSAttributedString.Key : Any] = [.font:boldFont!,
                                 .underlineStyle: NSUnderlineStyle.thick.rawValue,
                                 .foregroundColor : UIColor(named: "ice_blue")!]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        for i in 0 ..< boldPartsOfString.count {
            boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartsOfString[i] as String))
        }
        return boldString
    }


}
