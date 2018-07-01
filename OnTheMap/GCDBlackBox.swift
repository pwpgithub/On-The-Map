//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/5/18.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
