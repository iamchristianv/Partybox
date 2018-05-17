//
//  PartyDetails.swift
//  Partybox
//
//  Created by Christian Villa on 12/9/17.
//  Copyright © 2017 Christian Villa. All rights reserved.
//

import Firebase
import Foundation
import SwiftyJSON

class PartyDetails {
    
    // MARK: - Instance Properties
    
    var id: String = Partybox.defaults.none
    
    var name: String = Partybox.defaults.none

    var gameId: String = Partybox.defaults.none

    var status: String = Partybox.defaults.none

    var hostName: String = Partybox.defaults.none

    var timestamp: Int = Partybox.defaults.zero

    private var dataSource: PartyDetailsDataSource!

    // MARK: - Construction Functions

    static func construct(name: String, dataSource: PartyDetailsDataSource) -> PartyDetails {
        let details = PartyDetails()
        details.id = Partybox.defaults.randomPartyId()
        details.name = name
        details.gameId = Partybox.defaults.randomGameId()
        details.status = PartyDetailsStatus.waiting.rawValue
        details.hostName = Partybox.defaults.none
        details.timestamp = Partybox.defaults.zero
        details.dataSource = dataSource
        return details
    }

    static func construct(id: String, dataSource: PartyDetailsDataSource) -> PartyDetails {
        let details = PartyDetails()
        details.id = id
        details.name = Partybox.defaults.none
        details.gameId = Partybox.defaults.randomGameId()
        details.status = PartyDetailsStatus.waiting.rawValue
        details.hostName = Partybox.defaults.none
        details.timestamp = Partybox.defaults.zero
        details.dataSource = dataSource
        return details
    }

    static func construct(json: JSON, dataSource: PartyDetailsDataSource) -> PartyDetails {
        let details = PartyDetails()
        details.id = json[PartyDetailsKey.id.rawValue].stringValue
        details.name = json[PartyDetailsKey.name.rawValue].stringValue
        details.gameId = json[PartyDetailsKey.gameId.rawValue].stringValue
        details.status = json[PartyDetailsKey.status.rawValue].stringValue
        details.hostName = json[PartyDetailsKey.hostName.rawValue].stringValue
        details.timestamp = json[PartyDetailsKey.timestamp.rawValue].intValue
        details.dataSource = dataSource
        return details
    }

    // MARK: - Database Functions

    func update(values: [String: Any], callback: @escaping (String?) -> Void) {
        let path = self.dataSource.partyDetailsPath()

        Database.database().reference().child(path).updateChildValues(values, withCompletionBlock: {
            (error, reference) in

            callback(error?.localizedDescription)
        })
    }

    // MARK: - Notification Functions

    func startObservingChanges() {
        let path = self.dataSource.partyDetailsPath()

        Database.database().reference().child(path).observe(.childChanged, with: {
            (snapshot) in

            if snapshot.key == PartyDetailsKey.name.rawValue {
                self.name = snapshot.value as? String ?? self.name

                let name = Notification.Name(PartyDetailsNotification.nameChanged.rawValue)
                NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
            }

            if snapshot.key == PartyDetailsKey.gameId.rawValue {
                self.gameId = snapshot.value as? String ?? self.gameId

                let name = Notification.Name(PartyDetailsNotification.gameIdChanged.rawValue)
                NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
            }

            if snapshot.key == PartyDetailsKey.status.rawValue {
                self.status = snapshot.value as? String ?? self.status

                let name = Notification.Name(PartyDetailsNotification.statusChanged.rawValue)
                NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
            }

            if snapshot.key == PartyDetailsKey.hostName.rawValue {
                self.hostName = snapshot.value as? String ?? self.hostName

                let name = Notification.Name(PartyDetailsNotification.hostNameChanged.rawValue)
                NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
            }
        })
    }

    func stopObservingChanges() {
        let path = self.dataSource.partyDetailsPath()

        Database.database().reference().child(path).removeAllObservers()
    }
    
}
