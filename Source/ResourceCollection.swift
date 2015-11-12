//
//  ResourceCollection.swift
//  PopTop
//
//  Created by AJ Self on 11/10/15.
//  Copyright © 2015 Belly. All rights reserved.
//

public struct ResourceCollection<KeyType: Hashable, ResourceType> {
    typealias DictionaryType = [KeyType: ResourceType]

    private var dictionary = DictionaryType()

    var count: Int {
        return dictionary.count
    }

    subscript(key: KeyType) -> ResourceType? {
        get {
            return dictionary[key]
        }

        set {
            dictionary[key] = newValue!
        }
    }

    mutating func removeAll() {
        dictionary.removeAll()
    }
}