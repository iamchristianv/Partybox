//
//  Identifiable.swift
//  Partybox
//
//  Created by Christian Villa on 7/8/18.
//  Copyright © 2018 Christian Villa. All rights reserved.
//

import Foundation

class Identifiable {

    // MARK: - Remote Properties

    var id: String = Partybox.value.none

}

extension Identifiable: Hashable {

    var hashValue: Int {
        return self.id.hashValue
    }

    static func ==(lhs: Identifiable, rhs: Identifiable) -> Bool {
        return lhs.id == rhs.id
    }

}
