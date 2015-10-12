//
//  PopTop.swift
//  PopTop
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import UIKit

public class Manager {
    // MARK: - Properties
    public static let sharedInstance = Manager()
    
    /// Singleton available only. Ensures multiple instances are not possible.
    private init() {}
}