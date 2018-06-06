//
//  OrderedSet.swift
//  Partybox
//
//  Created by Christian Villa on 5/9/18.
//  Copyright © 2018 Christian Villa. All rights reserved.
//

import Foundation

class OrderedSet<Object: Hashable> {

    // MARK: - Initialization Functions

    var objects: [Object] = []

    private var hashValuesToIndexes: [Int: Int] = [:]

    var count: Int {
        return self.objects.count
    }

    // MARK: - Ordered Set Functions

    func add(_ object: Object) {
        if let index = self.hashValuesToIndexes[object.hashValue] {
            self.objects[index] = object
        } else {
            self.objects.append(object)
            self.hashValuesToIndexes[object.hashValue] = self.objects.count - 1
        }
    }

    func remove(_ object: Object) {
        if let index = self.hashValuesToIndexes[object.hashValue] {
            self.objects.remove(at: index)
            self.hashValuesToIndexes.removeValue(forKey: object.hashValue)

            for i in index ..< self.objects.count {
                let obj = self.objects[i]
                self.hashValuesToIndexes[obj.hashValue] = i
            }
        }
    }

    func fetch(index: Int) -> Object? {
        if index < 0 || index >= self.objects.count {
            return nil
        } else {
            return self.objects[index]
        }
    }

    func fetch(key: String) -> Object? {
        if let index = self.hashValuesToIndexes[key.hashValue] {
            return self.objects[index]
        } else {
            return nil
        }
    }

    func contains(index: Int) -> Bool {
        if index < 0 || index >= self.objects.count {
            return false
        } else {
            return true
        }
    }

    func contains(key: String) -> Bool {
        if self.hashValuesToIndexes[key.hashValue] != nil {
            return true
        } else {
            return false
        }
    }

    func random() -> Object? {
        if self.objects.count == 0 {
            return nil
        }

        let randomIndex = Int(arc4random()) % self.objects.count
        let randomObject = self.objects[randomIndex]

        return randomObject
    }

}