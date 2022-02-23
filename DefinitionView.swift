//
//  DefinitionView.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/17/21.
//

import UIKit

class DefinitionView: BottomSheetController{
    
    @IBOutlet weak var definitionView: UIView!
    @IBOutlet weak var definition: UILabel!
    @IBOutlet weak var definitionTitle: UILabel!
    
    
    override var contentView: UIView{
        return definitionView
    }
    
    
    var dismissCallback: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.userInitiatedDismissCallback = dismissCallback
        
    }
    

    
}

