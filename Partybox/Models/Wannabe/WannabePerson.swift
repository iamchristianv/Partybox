//
//  WannabePerson.swift
//  Partybox
//
//  Created by Christian Villa on 12/9/17.
//  Copyright © 2017 Christian Villa. All rights reserved.
//

import Foundation
import SwiftyJSON

enum WannabePersonKey: String {
    
    // MARK: - Database Keys
    
    case name
    
    case points
    
    case voteName
    
}

class WannabePerson {
    
    // MARK: - Instance Properties
    
    var name: String = ""
    
    var points: Int = 0
    
    var voteName: String = ""
    
    // MARK: - JSON Properties
    
    var json: [String: Any] {
        let json = [
            self.name: [
                WannabePersonKey.points.rawValue: self.points,
                WannabePersonKey.voteName.rawValue: self.voteName
            ]
        ] as [String: Any]
        
        return json
    }
    
    // MARK: - Initialization Methods
    
    init(name: String, JSON: JSON) {
        self.name = name
        self.points = JSON[WannabePersonKey.points.rawValue].intValue
        self.voteName = JSON[WannabePersonKey.voteName.rawValue].stringValue
    }
    
}
