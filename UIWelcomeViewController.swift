//
//  UIWelcomeViewController.swift
//  OxygenSaturation
//
//  Created by Pragya Prakash on 7/2/21.
//

import UIKit
import Lottie

class UIWelcomeViewController: UIViewController {

    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    
    var pulseView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hides top navigation bar on screen
        self.navigationController?.navigationBar.isHidden = true
        
        //Adds rounded edges for register button
        registerButton.layer.cornerRadius = 10
        
        //Adds shadow to view
        
         //Start AnimationView with animation name (without extension)
         
        pulseView = AnimationView()
         
        pulseView!.frame = animationView.bounds
        pulseView.animation = Animation.named("pulsingHeart")
         //Set animation content mode
         
        pulseView!.contentMode = .scaleAspectFit
         
         //Set animation loop mode
         
        pulseView!.loopMode = .loop
         
         //Adjust animation speed
         
        pulseView!.animationSpeed = 0.5
         
         animationView.addSubview(pulseView)
         
         //Play animation
         
        pulseView!.play()
        
    }
   
}
