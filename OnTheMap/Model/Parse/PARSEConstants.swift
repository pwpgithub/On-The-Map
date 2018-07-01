//
//  PARSEConstants.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/5/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation
import UIKit

// MARK: - PARSEClient (Constants)

extension PARSEClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: Parse
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
    }
    
    // MARK: HTTP Methods
    struct HTTPMethods {
        static let Get = "GET"
        static let Post = "POST"
        static let Put = "PUT"
    }
    
    // MAKE: HTTP Header Field Keys
    struct HTTPHeaderFieldKeys {
        static let XParseApplicationID = "X-Parse-Application-Id"
        static let XParseRestApiKey = "X-Parse-REST-API-Key"
        
        static let ContentType = "Content-Type"
    }
    
    // MAKE: HTTP Header Field Values
    struct HTTPHeaderFieldValues {
        static let ContentType = "application/json"
    }
    
    // MAKE: PARSE URL Keys
    struct URLKeys {
        static let ObjectID = "objectId"
    }
    
    // MAKE: Parameters Keys
    struct ParametersKeys {
        
        // MARK: PUTting a Student Location
        static let ObjectID = "objectId"
        
        
        // MARK: GETting Locations (Optionals)
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        
        // MARK: GETting A Location
        // example: https://parse.udacity.com/parse/classes/StudentLocation?where={"uniqueKey":"1234"}
        static let Where = "where"
        static let UniqueKey = "uniqueKey"
        
    }
    
    // MARK: Parameters Values
    struct ParametersValues {
        // MARK: GETting Locations (Optional)
        static let Limit = "100"
        static let Skip = "0"
        static let OrderByUpdateDate = "-updatedAt"
    }
    
    
    // MARK: PARSE Methods
    struct Methods {
        static let GetStudentLocation = "/StudentLocation"
        static let GetStudentsLocations = "/StudentLocation"
        
        static let PostStudentLocation = "/StudentLocation"
        
        static let PutStudentLocation = "/StudentLocation/<objectId>"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Results
        static let Results = "results"
        
        // MARK: Locations
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
    }
}
