//
//  UDACITYConvenience.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/6/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import Foundation
import FBSDKCoreKit

// MARK: - UDACITYClient (Convenience)

extension UDACITYClient {
    
    // MARK: Authenticate with username and password
    
    func authenticateWithUserNameAndPassword(_ hostViewController: UIViewController, _ username: String, _ password: String, completionHandlerForAuthenticate: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        postSession(username, password) { (success, results, error) in
            if success {
                
                // Get User ID
                if let results = results,
                    let account = results[JSONResponseKeys.Account] as? [String : AnyObject],
                    let userID = account[JSONResponseKeys.AccountKey] as? String {
                    
                    self.userID = userID
        
                    self.getUserPublicProfile(userID, completionHandlerForGetUserPorfile: { (success, userProfile, error) in
                        if success {
                            // Get firstName and lastName
                            
                            if let firstName = userProfile![JSONResponseKeys.FirstName] as? String,
                                let lastName = userProfile![JSONResponseKeys.LastName] as? String {
                                self.firstName = firstName
                                self.lastName = lastName
                       
                                completionHandlerForAuthenticate(true, nil)
                            } else {
                                completionHandlerForAuthenticate(false, NSError(domain: #function, code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not find keys: '\(JSONResponseKeys.FirstName)' and '\(JSONResponseKeys.LastName)' in \(userProfile!)"]))
                            }
                        } else {
                            completionHandlerForAuthenticate(false, error)
                        }
                    })
                } else {
                    completionHandlerForAuthenticate(false, NSError(domain: #function, code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not find Keys: '\(JSONResponseKeys.Account)' and '\(JSONResponseKeys.AccountKey)' in \(results!)"]))
                }
            } else {
                completionHandlerForAuthenticate(false, error)
            }
        }
    }
    
    
    // MARK: Authenticate with Facebook
    
    func authenticateWithFB(_ fbAccessToken: FBSDKAccessToken, completionHandlerForAuthWithFB: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        postSessionWithFB(fbAccessToken) { (success, results, error) in
            if success {
                if let account = results![JSONResponseKeys.Account] as? [String : AnyObject],
                    let userID = account[JSONResponseKeys.AccountKey] as? String {
                    
                    self.userID = userID
                    
                    self.getUserPublicProfile(userID, completionHandlerForGetUserPorfile: { (success, userProfile, error) in
                        
                        if success {
                            if let firstName = userProfile![JSONResponseKeys.FirstName] as? String,
                                let lastName = userProfile![JSONResponseKeys.LastName] as? String {
                                self.firstName = firstName
                                self.lastName = lastName
                                completionHandlerForAuthWithFB(true, nil)
                            } else {
                                completionHandlerForAuthWithFB(false, NSError(domain: #function, code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not find keys: '\(JSONResponseKeys.FirstName)' and '\(JSONResponseKeys.LastName)' in \(userProfile!)"]))
                            }
                        } else {
                            completionHandlerForAuthWithFB(false, error)
                        }
                    })
                } else {
                    completionHandlerForAuthWithFB(false, NSError(domain: #function, code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not find keys: '\(JSONResponseKeys.Account)' and '\(JSONResponseKeys.AccountKey)' in \(results!)"]))
                }
            } else {
                completionHandlerForAuthWithFB(false, error)
            }
        }
    }
    
    
    // MARK: POST Session Method (Login Udacity)
    
    func postSession(_ username: String, _ password: String, completionHandlerForPostSession: @escaping (_ success: Bool, _ results: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = [
            ParameterKeys.UserName : username,
            ParameterKeys.Password : password
        ]
        let method = Methods.PostSession
        let jsonBody = "{\"\(JSONBodyKeys.Udacity)\": {\"\(JSONBodyKeys.UserName)\": \"\(username)\", \"\(JSONBodyKeys.Password)\": \"\(password)\"}}"
        
        let _ = taskForUdacityPOSTMethod(method, parameters as [String : AnyObject], jsonBody) { (results, error) in
            
            if let error = error {
                completionHandlerForPostSession(false, nil, error)
            }else {
                completionHandlerForPostSession(true, results, nil)
            }
        }
    }
    
    
    // MARK: POST Session With Facebook (Login Udacity with Facebook)
    
    func postSessionWithFB(_ fbAccessToken: FBSDKAccessToken,  completionHandlerForPostSesstionWithFB: @escaping (_ success: Bool, _ results: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = [ParameterKeys.FBMobile : "{\"\(ParameterKeys.FBAccessToken)\" : \"\(fbAccessToken.tokenString!)\"}"]
        
        let method = Methods.PostSession
        
        let jsonBody = "{\"\(JSONBodyKeys.FBMobile)\": {\"\(JSONBodyKeys.FBAccessToken)\": \"\(fbAccessToken.tokenString!)\"}}"
        
        let _ = taskForUdacityPOSTMethod(method, parameters as [String : AnyObject], jsonBody) { (results, error) in
            
            if let error = error {
                completionHandlerForPostSesstionWithFB(false, nil, error)
            } else {
                print("PostWithFB: \(results!)")
                completionHandlerForPostSesstionWithFB(true, results, nil)
            }
        }
    }
    
    
    // MARK: GET User Public Profile
    
    func getUserPublicProfile(_ userID: String, completionHandlerForGetUserPorfile: @escaping (_ success: Bool, _ userProfile: [String : AnyObject]?,  _ error: NSError?) -> Void) {
        
        let parameters = [String : AnyObject]()
        
        let method = DataTask.substituteKeyInMethod(Methods.GetPublicUserData, key: URLKeys.UserID, value: userID)
        
        let _ = taskForUdacityGETMethod(method!, parameters) { (results, error) in
            
            if let error = error {
                completionHandlerForGetUserPorfile(false, nil, error)
            } else {
                if let userProfile = results![JSONResponseKeys.User] as? [String : AnyObject] {
                    completionHandlerForGetUserPorfile(true, userProfile, nil)
                } else {
                    completionHandlerForGetUserPorfile(false, nil, NSError(domain: #function, code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not find key: '\(JSONResponseKeys.User)' in \(results!)"]))
                }
            }
        }
    }
    
    
    // MARK: DELETE Session Method (Logout Udacity)
    
    func deleteSession(completionHandlerForDeleteSession: @escaping (_ success: Bool, _ rusults: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = [String : AnyObject]()
        let method = Methods.DeleteSession
        
        let _ = taskForUdacityDELETEMethod(method, parameters) { (results, error) in
            
            if let error = error {
                completionHandlerForDeleteSession(false, nil, error)
            } else {
                if let results = results![JSONResponseKeys.Session] as? [String : AnyObject] {
                    completionHandlerForDeleteSession(true, results as AnyObject, nil)
                } else {
                    completionHandlerForDeleteSession(false, nil, NSError(domain: #function, code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not find key: '\(JSONResponseKeys.Session)' in \(results!)"]))
                }
            }
        }
        
    }
}
