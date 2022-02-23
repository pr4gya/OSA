//
//  ShakeDirection.swift
//  OxygenSaturation WatchKit Extension
//
//  Created by Pragya Prakash on 8/2/21.
//

import Foundation


public enum ShakeDirection{
    case shakeDirectionUp
    case shakeDirectionDown
    case shakeDirectionLeft
    case shakeDirectionRight
    case shakeDirectionUnknown
    
    static func direction(_ x: Double, _ y: Double) -> ShakeDirection{
        
        let valueX = fabs(x) //returns absolute value of each element in vector
        let valueY = fabs(y)
        
        
        if valueX > valueY, x > 0{
            return.shakeDirectionRight
        }
        
        if valueX > valueY, x < 0{
            return.shakeDirectionLeft
        }
        
        if valueX < valueY, y > 0{
            return.shakeDirectionDown
        }
        
        if valueX < valueY, y < 0{
            return.shakeDirectionUp
        }
        return.shakeDirectionUnknown
    }
    
}
