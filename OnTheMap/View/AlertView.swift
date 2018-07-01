//
//  AlertView.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/11/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation
import UIKit

// MARK: 

func errorAlertView(_ message: String, _ presentController: UIViewController) {
    let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
        
    }
    controller.addAction(okAction)
    presentController.present(controller, animated: true, completion: nil)
}


