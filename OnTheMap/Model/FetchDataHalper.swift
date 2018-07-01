//
//  FetchDataHalper.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/6/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

// MARK: DataTask (FetchDataHelper)

extension DataTask {
    
    // Parse data as JSON
    
    static func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ parsedResult: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "\(ErrorMessages.ParsingJSONError.rawValue): '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: #function, code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // handle URLKeys
    
    static func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        
        if method.range(of: "<\(key)>") != nil {
            return method.replacingOccurrences(of: "<\(key)>", with: value)
        } else {
            return nil
        }
    }
    
}


