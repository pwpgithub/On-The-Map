//
//  PARSEClient.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/5/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

// MARK: - PARSEClient: NSObject

class PARSEClient: NSObject {
    
    // MARK: Properties
    
    // MARK: Init
    override init() {
        super.init()
    }
    
    // MARK: PARSE GET Method
    
    func taskForParseGETMethod(_ method: String, _ parameters: [String : AnyObject], completionHandlerForParseGETMethod: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let url = parseURLFromParameters(parameters, withPathExtentions: method)
        let urlString = url.absoluteString
        let newString = urlString.replacingOccurrences(of: ":%", with: "%3A%")
        let newUrl = URL(string: newString)
        let mutableRequest = NSMutableURLRequest(url: newUrl!)
        mutableRequest.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderFieldKeys.XParseApplicationID)
        mutableRequest.addValue(Constants.RestApiKey, forHTTPHeaderField: HTTPHeaderFieldKeys.XParseRestApiKey)
        
        return DataTask.fetchData(mutableRequest as URLRequest, completionHandlerForFetchData: completionHandlerForParseGETMethod)
    }
    
    
    // MARK: PARSE POST Method
    
    func taskForParsePOSTMethod(_ method: String, _ parameters: [String : AnyObject], _ jsonBody: String, completionHandlerForParsePOSTMethod: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let url = parseURLFromParameters(parameters, withPathExtentions: method)
        
        let mutalbeRequest = NSMutableURLRequest(url: url)
        
        mutalbeRequest.httpMethod = HTTPMethods.Post
        mutalbeRequest.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderFieldKeys.XParseApplicationID)
        mutalbeRequest.addValue(Constants.RestApiKey, forHTTPHeaderField: HTTPHeaderFieldKeys.XParseRestApiKey)
        mutalbeRequest.addValue(HTTPHeaderFieldValues.ContentType, forHTTPHeaderField: HTTPHeaderFieldKeys.ContentType)
        mutalbeRequest.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        return DataTask.fetchData(mutalbeRequest as URLRequest, completionHandlerForFetchData: completionHandlerForParsePOSTMethod)
    }
    
    
    // MARK: PARSE PUT Method
    
    func taskForParsePUTMethod(_ method: String, _ parameters: [String : AnyObject], _ jsonBody: String, completionHandlerForParsePUTMethod: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let url = parseURLFromParameters(parameters, withPathExtentions: method)
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethods.Put
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderFieldKeys.XParseApplicationID)
        request.addValue(Constants.RestApiKey, forHTTPHeaderField: HTTPHeaderFieldKeys.XParseRestApiKey)
        request.addValue(HTTPHeaderFieldValues.ContentType, forHTTPHeaderField: HTTPHeaderFieldKeys.ContentType)
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        return DataTask.fetchData(request, completionHandlerForFetchData: completionHandlerForParsePUTMethod)
    }
}

// MARK: - PARSEClient (Helpers)

extension PARSEClient {
    
    // MARK: URL From Parameters
    func parseURLFromParameters(_ parameters: [String : AnyObject], withPathExtentions: String?) ->  URL {
        var components = URLComponents()
        components.scheme = PARSEClient.Constants.ApiScheme
        components.host = PARSEClient.Constants.ApiHost
        components.path = PARSEClient.Constants.ApiPath + (withPathExtentions ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
    
}


// MARK: - PARSEClient (Singleton)

extension PARSEClient {
    class func sharedInstance() -> PARSEClient{
        struct Singleton {
            static var sharedInstance = PARSEClient()
        }
        return Singleton.sharedInstance
    }
}
