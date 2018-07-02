//
//  PARSEStudent.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/5/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import Foundation

// MARK: - PARSEUserLocation

struct PARSEUserLocation {
    
    // Get From UDACITY Server
    var firstName: String!
    var lastName: String!
    var uniqueKey: String!
    
    // Get From PARSE Server
    var objectId: String!
    var createdAt: String!
    var updatedAt: String!
    
    // Get From UI
    var latitude: Double!
    var longitude: Double!
    var mapString: String!
    var mediaURL: String!
    
    // init
    init(dictionary: [String : AnyObject]) {
        firstName = dictionary[PARSEClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[PARSEClient.JSONResponseKeys.LastName] as? String
        uniqueKey = dictionary[PARSEClient.JSONResponseKeys.UniqueKey] as? String
        
        createdAt = dictionary[PARSEClient.JSONResponseKeys.CreatedAt] as? String
        objectId = dictionary[PARSEClient.JSONResponseKeys.ObjectID] as? String
        updatedAt = dictionary[PARSEClient.JSONResponseKeys.UpdatedAt] as? String
        
        latitude = dictionary[PARSEClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[PARSEClient.JSONResponseKeys.Longitude] as? Double
        mapString = dictionary[PARSEClient.JSONResponseKeys.MapString] as? String
        mediaURL = dictionary[PARSEClient.JSONResponseKeys.MediaURL] as? String
    }
    
    
    // MARK: Get locations array
    static func userLocationsFromResults(_ resultsArray: [[String : AnyObject]]) -> [PARSEUserLocation] {
        
        var locations = [PARSEUserLocation]()
        
        for result in resultsArray {
            let location = PARSEUserLocation(dictionary: result)
            locations.append(location)
        }
        
        return locations
    }
}


extension PARSEUserLocation: Equatable{}

func ==(lhs: PARSEUserLocation, rhs: PARSEUserLocation) -> Bool {
    return lhs.objectId == rhs.objectId
}
