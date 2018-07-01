//
//  UDACITYConstants.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/5/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation
import UIKit

// MARK: - UDACITYClient (Constants)

extension UDACITYClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: Udacity
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        
        // MARK: Facebook
        static let UdacityFBAppID = "365362206864879"
        static let UdacityFBURLSchemeSuffix = "onthemap"
    }
    
    // MARK: HTTP Methods
    struct HTTPMethods {
        static let GetMethod = "GET"
        static let PostMethod = "POST"
        static let DeleteMethod = "DELETE"
    }
    
    
    // MARK: HTTP Header Field Keys
    struct HTTPHeaderFieldKeys {
        static let XSRF = "X-XSRF-TOKEN"
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
    
    // MARK: HTTP Header Field Values
    struct HTTPHeaderFieldValues {
        static let Accept = "application/json"
        static let ContentType = "application/json"
    }
    
    // MARK: HTTP Cookie Tokens
    
    struct HTTPCookieTokens {
        static let XSRFToken = "XSRF-TOKEN"
    }
    
    // MARK: UDACITY Methods
    struct Methods {
        
        static let PostSession = "/session"
        static let DeleteSession = "/session"
        
        // Post With Facebook
        static let PostSessionWithFB = "/session"
        
        // Get User Profile
        static let GetPublicUserData = "/users/<user_id>"
    }
    
    // MARK: ParameterKeys
    struct ParameterKeys {
        // Udacity
        static let Udacity = "udacity"
        static let UserName = "username"
        static let Password = "password"
        
        // Facebook
        static let FBMobile = "facebook_mobile"
        static let FBAccessToken = "access_token"
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let UserName = "username"
        static let Password = "password"
        
        // Facebook
        static let FBMobile = "facebook_mobile"
        static let FBAccessToken = "access_token"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "user_id"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // Account
        static let Account = "account"
        
        static let Registered = "registered"
        static let AccountKey = "key"
        
        // Session
        static let Session = "session"
        
        static let SessionID = "id"
        static let Expiration = "expiration"
        
        // User Porfile
        static let User = "user"
        
        static let UserKey = "key"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
}
