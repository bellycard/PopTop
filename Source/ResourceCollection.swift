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

    /// Returns the number of items currently in the collection
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

    /// Removes all items in the collection
    mutating func removeAll() {
        dictionary.removeAll()
    }

    /// Remove and return return the element with provided key
    mutating func remove(key: KeyType) -> ResourceType? {
        return dictionary.removeValueForKey(key)
    }
}