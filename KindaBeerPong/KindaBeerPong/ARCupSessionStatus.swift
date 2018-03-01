//
//  ARCupSessionStatus.swift
//  KindaBeerPong
//
//  Created by Piera Marchesini on 28/02/18.
//  Copyright © 2018 Piera Marchesini. All rights reserved.
//

import Foundation
import UIKit

enum ARCupSessionStatus: String, CustomStringConvertible {
    case initialized = "initialized"
    case ready = "ready"
    case temporarilyUnavailable = "temporarily unavailable"
    case failed = "failed"
    
    var description: String {
        switch self {
        case .initialized:
            return "👀 Look for a plane to place your cup"
        case .ready:
            return "🍺 Click any plane to place your cup!"
        case .temporarilyUnavailable:
            return "😱 Adjusting alcoholism levels. Please wait"
        case .failed:
            return "⛔ Alcohol crisis! Please restart App"
        }
    }
}
