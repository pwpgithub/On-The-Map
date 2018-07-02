//
//  LocationStore.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/15/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

// MARK: LocationStore

class LocationStore {
    
    // MARK: Properties
    var allLocations = [PARSEUserLocation]()
    
    class func sharedInstance() -> LocationStore {
        struct Singleton {
            static var sharedInstance = LocationStore()
        }
        return Singleton.sharedInstance
    }
    
    private init() {
        
    }
}
