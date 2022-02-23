//
//  WatchShakerHandler.swift
//  OxygenSaturation WatchKit Extension
//
//  Created by Pragya Prakash on 8/2/21.
//

/// Discussion:
/// - Typedef of block to be invoked when shake data is available.

//public class WatchShakerHandler{
     public typealias WatchShakerHandler = ((ShakeSensibility?, ShakeCoordinates?, ShakeDirection? ,Error?) -> Void)
//}

