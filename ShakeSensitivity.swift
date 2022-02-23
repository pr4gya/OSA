//
//  ShakeSensibility.swift
//  OxygenSaturation WatchKit Extension
//
//  Created by Pragya Prakash on 8/2/21.
//

//defining  variables of desired shake


public enum ShakeSensibility: Double{
    
    public typealias RawValue = Double
    
    case shakeSensitivitySoftest = 0.1
    case shakeSensitivitySoft = 0.7
    case shakeSensitivityNormal = 1.0
    case shakeSensitivityHard = 1.2
    case shakeSensitivityHardest = 2.0
}
