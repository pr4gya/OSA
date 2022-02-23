//
//  UIInformationView.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/17/21.
//

import UIKit


class UIInformationView: UIViewController {
    
    
    @IBOutlet weak var apneaTF: UITextView!
    @IBOutlet weak var topBarButton: BadgeBarButtonItem!
    @IBOutlet weak var disclaimerTF: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.setNavigationBarHidden(true, animated: false)
       
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped(_:)))
        
        
        
        apneaTF.addGestureRecognizer(tap)
        
        let normalFont = UIFont.systemFont(ofSize: 16)
        let boldFont = UIFont.italicSystemFont(ofSize: 16)
        //boldFont
        
        
        apneaTF.attributedText = addBoldText(fullString: "A disorder that is characterized by obstructive apneas, hypoxia, and/or respiratory effort related arousals caused by repetitive complete or partial collapse of the upper airway during sleep.", boldPartsOfString: ["apneas","hypoxia"], font: normalFont, boldFont: boldFont)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBadges()
    }
    
    private func setBadges() {
        if let _ = try? UserDefaults.standard.getObject(forKey: "sleepStart", castTo: Date.self),
           let _ = try? UserDefaults.standard.getObject(forKey: "sleepEnd", castTo: Date.self){
            topBarButton.badgeNumber = 0
        } else {
            topBarButton.badgeNumber = 1
        }
    }
//
//    var polysomnography = disclaimerTF.text
//    polysomnography.addGestureRecognizer(tap)
//    polysomnography.attributedText = addBoldText(fullString: disclaimerTF.text, boldPartsOfString: ["polysomnography"], font: normalFont, boldFont: boldFont)
//
    
    @objc func textFieldTapped(_ sender: UITapGestureRecognizer) {
        let myTextView = sender.view as! UITextView
        let location = sender.location(in: myTextView)
        if let word = getWord(at: location, in: myTextView) {
            
            if word == "apneas" || word == "hypoxia" {
                //Hypopnea is a sleep breathing disorder that causes shallow breathing episodes, called hypopneas, while people sleep1. This restricted breathing lowers blood oxygen levels and, untreated, can be a risk factor for conditions like cardiovascular disease and diabetes.
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(identifier: "definitionview") as! DefinitionView
//                self.present(vc, animated: true)
                
                self.tabBarController?.present(vc, animated: true)

            }
            
        } else {
            print("Touched Word not found")
        }
    }
    
    func getWord(at position: CGPoint, in textView: UITextView) -> String? {
        guard let tapPos = textView.closestPosition(to: position) else {
            print("No word found")
            return nil
        }
        
        //fetch the word at this position (or nil, if not available)
        guard let wordRange = textView.tokenizer.rangeEnclosingPosition(tapPos, with: .word, inDirection: UITextDirection(rawValue: NSWritingDirection.rightToLeft.rawValue))
            else {
                print("getWord() wordRange is nil")
                return nil
        }
        
        return textView.text(in: wordRange)
    }
    
}

func addBoldText(fullString: NSString, boldPartsOfString: Array<NSString>, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
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
