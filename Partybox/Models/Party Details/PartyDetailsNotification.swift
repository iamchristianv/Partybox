//
//  PartyDetailsNotification.swift
//  Partybox
//
//  Created by Christian Villa on 5/7/18.
//  Copyright © 2018 Christian Villa. All rights reserved.
//

import Foundation

enum PartyDetailsNotification: String {

    // MARK: - Party Details Notifications

    case nameChanged = "PartyDetailsNotification/nameChanged"

    case gameChanged = "PartyDetailsNotification/gameChanged"

    case statusChanged = "PartyDetailsNotification/statusChanged"

    case hostChanged = "PartyDetailsNotification/hostChanged"

}
