//
//  String+Blank.swift
//  PopTop
//
//  Created by AJ Self on 1/22/16.
//  Copyright © 2016 Belly. All rights reserved.
//

import Foundation

extension String {
    /// Checks if a string is empty or contains only white space characters
    var isBlank: Bool {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()

        if self.isEmpty || self.stringByTrimmingCharactersInSet(whitespaceSet) == "" {
            return true
        }

        return false
    }
}