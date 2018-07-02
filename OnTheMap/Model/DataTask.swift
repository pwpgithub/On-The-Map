//
//  DataTask.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/6/18.
//  Copyright © 2018 . All rights reserved.
//


import Foundation

enum ErrorMessages: String {
    case LoginEmptyError = "User name or password appears to be empty. \nPlease try again"
    case LoginInvalidError = "User name or password appears to be incorrect. \nPlease try again"
    case StatusCodeError = "Your request returned a status code other than 2xx!"
    case NoDatatError = "No data was returned by the request!"
    case ParsingJSONError = "Could not parse data as JSON"
}

// MARK: DataTask: NSObject

class DataTask: NSObject {
    
    // MARK: Properties
    
    private static let session = URLSession.shared
    
    // MARK: fetchData
    
    static func fetchData(_ request: URLRequest, completionHandlerForFetchData: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ errorString: String) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForFetchData(nil, NSError(domain: #function, code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                let defaultDescription = (error! as NSError).userInfo[NSLocalizedDescriptionKey]
                sendError(defaultDescription as! String)
                return
            }
         
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                var errorString: String!
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    
                    if statusCode == 400 {
                        errorString = ErrorMessages.LoginEmptyError.rawValue
                    } else if statusCode == 403 {
                        errorString = ErrorMessages.LoginInvalidError.rawValue
                    }else {
                        errorString = ErrorMessages.StatusCodeError.rawValue
                    }
                }
                sendError(errorString)
                return
            }
            
            guard let data = data else {
                sendError(ErrorMessages.NoDatatError.rawValue)
                return
            }
            
            // skip first 5 charactors if UDATCITY
            
            var newData = data
            if (request.url?.absoluteString.contains(UDACITYClient.Constants.ApiHost))! {
                let range = Range(uncheckedBounds: (5, Int(data.count)))
                newData = data.subdata(in: range)
            }
            
            convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForFetchData)
        }
        
        task.resume()
        
        return task
    }
}



