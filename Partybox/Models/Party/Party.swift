//
//  Party.swift
//  Partybox
//
//  Created by Christian Villa on 10/7/17.
//  Copyright © 2017 Christian Villa. All rights reserved.
//

import Firebase
import Foundation
import SwiftyJSON

class Party: Identifiable {

    // MARK: - Remote Properties

    var id: String = Partybox.value.none

    var name: String = Partybox.value.none

    var hostId: String = Partybox.value.none

    var timestamp: Int = Partybox.value.zero

    var guests: OrderedSet<PartyGuest> = OrderedSet<PartyGuest>()

    var wannabe: Wannabe = Wannabe()

    // MARK: - Local Properties

    var userId: String = Partybox.value.none

    var games: OrderedSet<PartyGame> = OrderedSet<PartyGame>()

    // MARK: - Construction Functions

    static func construct(name: String) -> Party {
        let party = Party()
        party.id = Party.randomPartyId()
        party.name = name
        party.hostId = Partybox.value.none
        party.timestamp = Partybox.value.zero
        party.guests = OrderedSet<PartyGuest>()
        party.wannabe = Wannabe.construct(partyId: party.id)
        party.userId = Partybox.value.none
        party.games = OrderedSet<PartyGame>()
        party.games.add(party.wannabe)
        return party
    }

    static func construct(id: String) -> Party {
        let party = Party()
        party.id = id
        party.name = Partybox.value.none
        party.hostId = Partybox.value.none
        party.timestamp = Partybox.value.zero
        party.guests = OrderedSet<PartyGuest>()
        party.wannabe = Wannabe.construct(partyId: party.id)
        party.userId = Partybox.value.none
        party.games = OrderedSet<PartyGame>()
        party.games.add(party.wannabe)
        return party
    }

    // MARK: - JSON Functions

    private func merge(json: JSON) {
        for (key, value) in json {
            if key == PartyKey.id.rawValue {
                self.id = value.stringValue
            }

            if key == PartyKey.name.rawValue {
                self.name = value.stringValue
            }

            if key == PartyKey.hostId.rawValue {
                self.hostId = value.stringValue
            }

            if key == PartyKey.timestamp.rawValue {
                self.timestamp = value.intValue
            }

            if key == PartyKey.guests.rawValue {
                for (_, json) in value {
                    let guest = PartyGuest.construct(json: json)
                    self.guests.add(guest)
                }
            }

            if key == PartyKey.wannabe.rawValue {
                self.wannabe = Wannabe.construct(partyId: self.id)
            }
        }
    }

    // MARK: - Party Functions

    func start(callback: @escaping (_ error: String?) -> Void) {
        var path = "\(PartyboxKey.parties.rawValue)/\(self.id)"

        Partybox.firebase.database.child(path).observeSingleEvent(of: .value, with: {
            (snapshot) in

            if snapshot.exists() {
                callback("We ran into a problem while starting your party\n\nPlease try again")
                return
            }

            let values = [
                PartyKey.id.rawValue: self.id,
                PartyKey.name.rawValue: self.name,
                PartyKey.hostId.rawValue: self.hostId,
                PartyKey.timestamp.rawValue: ServerValue.timestamp()
            ] as [String: Any]

            path = "\(PartyboxKey.parties.rawValue)/\(self.id)"

            Partybox.firebase.database.child(path).updateChildValues(values, withCompletionBlock: {
                (error, reference) in

                if error != nil {
                    callback("We ran into a problem while starting your party\n\nPlease try again")
                    return
                }

                callback(nil)
            })
        })
    }

    func end(callback: @escaping (_ error: String?) -> Void) {
        let path = "\(PartyboxKey.parties.rawValue)/\(self.id)"

        Partybox.firebase.database.child(path).removeValue(completionBlock: {
            (error, reference) in

            callback(error?.localizedDescription)
        })
    }

    func enter(name: String, callback: @escaping (_ error: String?) -> Void) {
        var path = "\(PartyboxKey.parties.rawValue)/\(self.id)"

        Partybox.firebase.database.child(path).observeSingleEvent(of: .value, with: {
            (snapshot) in

            if !snapshot.exists() {
                callback("We couldn't find a party with your invite code\n\nPlease try again")
                return
            }

            path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.guests.rawValue)"

            let id = Partybox.firebase.database.child(path).childByAutoId().key

            self.userId = id

            let guest = PartyGuest.construct(id: id, name: name)

            let values = [
                guest.id: [
                    PartyGuestKey.id.rawValue: guest.id,
                    PartyGuestKey.name.rawValue: guest.name,
                    PartyGuestKey.points.rawValue: guest.points
                ]
            ] as [String: Any]

            path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.guests.rawValue)"

            Partybox.firebase.database.child(path).updateChildValues(values, withCompletionBlock: {
                (error, reference) in

                if error != nil {
                    callback("We ran into a problem while joining your party\n\nPlease try again")
                    return
                }

                path = "\(PartyboxKey.parties.rawValue)/\(self.id)"

                Partybox.firebase.database.child(path).observeSingleEvent(of: .value, with: {
                    (snapshot) in

                    if !snapshot.exists() {
                        callback("We ran into a problem while joining your party\n\nPlease try again")
                        return
                    }

                    guard let data = snapshot.value as? [String: Any] else {
                        callback("We ran into a problem while joining your party\n\nPlease try again")
                        return
                    }

                    let json = JSON(data)

                    self.merge(json: json)

                    self.startObservingChanges()

                    callback(nil)
                })
            })
        })
    }

    func exit(callback: @escaping (_ error: String?) -> Void) {
        self.stopObservingChanges()

        let path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.guests.rawValue)/\(self.userId)"

        Partybox.firebase.database.child(path).removeValue(completionBlock: {
            (error, reference) in

            callback(error?.localizedDescription)
        })
    }

    // MARK: - Database Functions

    func remove(guestId: String, callback: @escaping (_ error: String?) -> Void) {
        let values = [guestId: Partybox.value.null]

        let path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.guests.rawValue)"

        Partybox.firebase.database.child(path).updateChildValues(values, withCompletionBlock: {
            (error, reference) in

            callback(error?.localizedDescription)
        })
    }

    func change(hostId: String, callback: @escaping (_ error: String?) -> Void) {
        let values = [PartyKey.hostId.rawValue: hostId]

        let path = "\(PartyboxKey.parties.rawValue)/\(self.id)"

        Partybox.firebase.database.child(path).updateChildValues(values, withCompletionBlock: {
            (error, reference) in

            callback(error?.localizedDescription)
        })
    }

    func change(name: String, hostId: String, callback: @escaping (_ error: String?) -> Void) {
        let values = [PartyKey.name.rawValue: name, PartyKey.hostId.rawValue: hostId]

        let path = "\(PartyboxKey.parties.rawValue)/\(self.id)"

        Partybox.firebase.database.child(path).updateChildValues(values, withCompletionBlock: {
            (error, reference) in

            callback(error?.localizedDescription)
        })
    }

    // MARK: - Notification Functions

    private func startObservingChanges() {
        var path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.name.rawValue)"

        Partybox.firebase.database.child(path).observe(.value, with: {
            (snapshot) in

            guard let data = snapshot.value as? String else {
                return
            }

            self.name = data

            let name = Notification.Name(PartyNotification.nameChanged.rawValue)
            NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
        })

        path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.hostId.rawValue)"

        Partybox.firebase.database.child(path).observe(.value, with: {
            (snapshot) in

            guard let data = snapshot.value as? String else {
                return
            }

            self.hostId = data

            let name = Notification.Name(PartyNotification.hostIdChanged.rawValue)
            NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
        })

        path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.guests.rawValue)"

        Partybox.firebase.database.child(path).observe(.childAdded, with: {
            (snapshot) in

            guard let data = snapshot.value as? [String: Any] else {
                return
            }

            let json = JSON(data)

            let guest = PartyGuest.construct(json: json)

            self.guests.add(guest)

            let name = Notification.Name(PartyNotification.guestAdded.rawValue)
            NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
        })

        path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.guests.rawValue)"

        Partybox.firebase.database.child(path).observe(.childChanged, with: {
            (snapshot) in

            guard let data = snapshot.value as? [String: Any] else {
                return
            }

            let json = JSON(data)

            let guest = PartyGuest.construct(json: json)

            self.guests.add(guest)

            let name = Notification.Name(PartyNotification.guestChanged.rawValue)
            NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
        })

        path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.guests.rawValue)"

        Partybox.firebase.database.child(path).observe(.childRemoved, with: {
            (snapshot) in

            guard let data = snapshot.value as? [String: Any] else {
                return
            }

            let json = JSON(data)

            let guest = PartyGuest.construct(json: json)

            self.guests.remove(guest)

            let name = Notification.Name(PartyNotification.guestRemoved.rawValue)
            NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
        })
    }

    private func stopObservingChanges() {
        var path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.name.rawValue)"

        Partybox.firebase.database.child(path).removeAllObservers()

        path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.hostId.rawValue)"

        Partybox.firebase.database.child(path).removeAllObservers()

        path = "\(PartyboxKey.parties.rawValue)/\(self.id)/\(PartyKey.guests.rawValue)"

        Partybox.firebase.database.child(path).removeAllObservers()
    }

    // MARK: - Utility Functions

    private static func randomPartyId() -> String {
        var randomPartyId = ""

        let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                       "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

        for _ in 1...5 {
            let randomIndex = Int(arc4random())
            let randomLetter = letters[randomIndex % letters.count]
            let randomNumber = String(numbers[randomIndex % numbers.count])

            randomPartyId += (randomIndex % 2 == 0 ? randomLetter : randomNumber)
        }

        return randomPartyId
    }
    
}

extension Party: Hashable {

    var hashValue: Int {
        return self.id.hashValue
    }

    static func ==(lhs: Party, rhs: Party) -> Bool {
        return lhs.id == rhs.id
    }

}
