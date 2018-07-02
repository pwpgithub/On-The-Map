//
//  PARSEConvenience.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/6/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

// MARK: - PARSEClient (Convenience)

extension PARSEClient {
    
    // MARK: Get All Locations
    
    func getAllLocations(completionHandlerForGetAllLocations: @escaping (_ success: Bool, _ locations: [PARSEUserLocation]?, _ error: NSError?) -> Void) {
        
        let parameters = [
                            ParametersKeys.Limit : ParametersValues.Limit,
                            ParametersKeys.Skip : ParametersValues.Skip,
                            ParametersKeys.Order : ParametersValues.OrderByUpdateDate
            ] as [String : AnyObject]
        
        let method = Methods.GetStudentsLocations
        
        let _ = taskForParseGETMethod(method, parameters) { (results, error) in
            
            if let error = error {
                completionHandlerForGetAllLocations(false, nil, error)
            } else {
                if let resultsArray = results![JSONResponseKeys.Results] as? [[String : AnyObject]] {
                    let locations = PARSEUserLocation.userLocationsFromResults(resultsArray)

                    LocationStore.sharedInstance().allLocations = locations
                    completionHandlerForGetAllLocations(true, locations, nil)
                } else {
                    completionHandlerForGetAllLocations(false, nil, NSError(domain: #function, code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not find key: '\(JSONResponseKeys.Results)' in \(results!)"]))
                }
            }
        }
    }
    
    
    // MARK: Get User Location
    
    func getUserLocation(_ accountKey: String, completionHanderForGetUserLocation: @escaping (_ success: Bool, _ userLocations: [PARSEUserLocation]?, _ error: NSError?) -> Void) {
        
        let whereValue = "{\"\(ParametersKeys.UniqueKey)\":\"\(accountKey)\"}"
        
        let parameters = [ParametersKeys.Where : "\(whereValue)",
                            ParametersKeys.Order : ParametersValues.OrderByUpdateDate]
        let method = Methods.GetStudentLocation
        let _ = taskForParseGETMethod(method, parameters as [String : AnyObject]) { (results, error) in
            
            if let error = error {
                completionHanderForGetUserLocation(false, nil, error)
            } else {
                if let results = results?[JSONResponseKeys.Results] as? [[String : AnyObject]] {
                    let userLocations = PARSEUserLocation.userLocationsFromResults(results)
                    completionHanderForGetUserLocation(true, userLocations, nil)
                } else {
                    completionHanderForGetUserLocation(false, nil, NSError(domain: #function, code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not find key: '\(JSONResponseKeys.Results)' in \(results!)"]))
                }
            }
        }
    }
    
    // MARK: Using Put to Update An Existing Location
    
    func updateUserLocation(_ userLocation: PARSEUserLocation, completionHandlerForUpdateUserLocation: @escaping (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = [ParametersKeys.ObjectID : userLocation.objectId!]
        
        let method = DataTask.substituteKeyInMethod(Methods.PutStudentLocation, key: URLKeys.ObjectID, value: userLocation.objectId)
        
        let jsonBody = "{\"\(JSONBodyKeys.UniqueKey)\": \"\(userLocation.uniqueKey!)\", \"\(JSONBodyKeys.FirstName)\": \"\(userLocation.firstName!)\", \"\(JSONBodyKeys.LastName)\": \"\(userLocation.lastName!)\", \"\(JSONBodyKeys.MapString)\": \"\(userLocation.mapString!)\", \"\(JSONBodyKeys.MediaURL)\": \"\(userLocation.mediaURL!)\", \"\(JSONBodyKeys.Latitude)\": \(userLocation.latitude!), \"\(JSONBodyKeys.Longitude)\": \(userLocation.longitude!)}"
        
        let _ = taskForParsePUTMethod(method!, parameters as [String : AnyObject], jsonBody) { (result, error) in
            
            if let error = error {
                completionHandlerForUpdateUserLocation(false, nil, error)
            } else {
                completionHandlerForUpdateUserLocation(true, result, nil)
            }
        }
    }
    
    
    // MARK: Using Post to Create A New Location
    
    func createUserLocation(_ userLocation: PARSEUserLocation, completionHandlerForCreateUserLocation: @escaping (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = [String : AnyObject]()
        
        let method = Methods.PostStudentLocation
        
        let jsonBody = "{\"\(JSONBodyKeys.UniqueKey)\": \"\(userLocation.uniqueKey!))\", \"\(JSONBodyKeys.FirstName)\": \"\(userLocation.firstName!)\", \"\(JSONBodyKeys.LastName)\": \"\(userLocation.lastName!)\", \"\(JSONBodyKeys.MapString)\": \"\(userLocation.mapString!)\", \"\(JSONBodyKeys.MediaURL)\": \"\(userLocation.mediaURL!)\", \"\(JSONBodyKeys.Latitude)\": \(userLocation.latitude!), \"\(JSONBodyKeys.Longitude)\": \(userLocation.longitude!)}"
        
        
        let _ = taskForParsePOSTMethod(method, parameters as [String : AnyObject], jsonBody) { (result, error) in
            
            if let error = error {
                completionHandlerForCreateUserLocation(false, nil, error)
            } else {
                completionHandlerForCreateUserLocation(true, result, nil)
                
            }
        }
        
    }
}
