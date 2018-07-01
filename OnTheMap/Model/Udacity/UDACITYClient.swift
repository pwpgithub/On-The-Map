//
//  UDACITYClient.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/5/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

// MARK: - UDACITYClient: NSObject

class UDACITYClient: NSObject {
    
    // MARK: Properties
    
    var firstName: String? = nil
    var lastName: String? = nil
    var userID: String? = nil
    
    // GET Method
    func taskForUdacityGETMethod(_ method: String, _ parameters: [String : AnyObject], completionHandlerForUdacityGETMethod: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let url = udacityURLFromParamters(parameters, withPathExtentions: method)
    
        let request = URLRequest(url: url)
        
        return DataTask.fetchData(request, completionHandlerForFetchData: completionHandlerForUdacityGETMethod)
    }
    
    // POST Method
    
    func taskForUdacityPOSTMethod(_ method: String, _ parameters: [String : AnyObject], _ jsonBody: String, completionHandlerForUdacityPOSTMethod: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let url = udacityURLFromParamters(parameters, withPathExtentions: method)
        
        var urlString = url.absoluteString
        urlString = urlString.replacingOccurrences(of: ":%", with: "%3A%")
        
        let newUrl = URL(string: urlString)
        
        let mutableRequest = NSMutableURLRequest(url: newUrl!)
        mutableRequest.httpMethod = HTTPMethods.PostMethod
        mutableRequest.addValue(HTTPHeaderFieldValues.Accept, forHTTPHeaderField: HTTPHeaderFieldKeys.Accept)
        mutableRequest.addValue(HTTPHeaderFieldValues.ContentType, forHTTPHeaderField: HTTPHeaderFieldKeys.ContentType)
        mutableRequest.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        return DataTask.fetchData(mutableRequest as URLRequest, completionHandlerForFetchData: completionHandlerForUdacityPOSTMethod)
    }
    
    // DELETE Method
    
    func taskForUdacityDELETEMethod(_ method: String, _ parameters: [String : AnyObject],  completionHandlerForUdacityDELETEMethod: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let url = udacityURLFromParamters(parameters, withPathExtentions: method)
        
        let mutableRequest = NSMutableURLRequest(url: url)
        mutableRequest.httpMethod = HTTPMethods.DeleteMethod
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == HTTPCookieTokens.XSRFToken {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            mutableRequest.setValue(xsrfCookie.value, forHTTPHeaderField: HTTPHeaderFieldKeys.XSRF)
        }
        
        return DataTask.fetchData(mutableRequest as URLRequest, completionHandlerForFetchData: completionHandlerForUdacityDELETEMethod)
    }
}

// MARK: - UDACITYClient (Helpers)

extension UDACITYClient {
    
    // URL From Paramters
    func udacityURLFromParamters(_ parameters: [String : AnyObject], withPathExtentions: String?) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtentions ?? "")
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
    
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
    }
}

// MARK: - UDACITYClient (Singleton)

extension UDACITYClient {
    class func sharedInstance() -> UDACITYClient {
        struct Singleton {
            static var sharedInstance = UDACITYClient()
        }
        return Singleton.sharedInstance
    }
}
