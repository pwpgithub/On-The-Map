//
//  OTMTabBarViewController.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/7/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

// MARK: - OTMTabBarViewController: UITabBarController

class OTMTabBarViewController: UITabBarController {

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItems()
    }
    
    
    // MARK: Actions
    
    @objc func logout() {
        
        UDACITYClient.sharedInstance().deleteSession { (success, results, error) in
            if success {
                performUIUpdatesOnMain {
                    if FBSDKAccessToken.current() != nil {
                        FBSDKLoginManager().logOut()
                        FBSDKAccessToken.setCurrent(nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                errorAlertView(error?.userInfo[NSLocalizedDescriptionKey] as! String, self)
            }
        }
    }
    
    
    @objc func updateLocations() {

        if self.selectedIndex == 0 {
            let controller = self.selectedViewController as!OTMMapViewController
            controller.loadMapLocations()
            
        } else {
            let contoller = self.selectedViewController as! OTMTableViewController
            contoller.loadTableLocations()
        }
    }
    
    @objc func addLocation() {
        
        let accountKey = UDACITYClient.sharedInstance().userID
        
        PARSEClient.sharedInstance().getUserLocation(accountKey!) { (success, userLocation, error) in
            
            if success {
                    performUIUpdatesOnMain {
                        self.alertView("The location exists!\n Do you want to set new location?")
                }
            } else {
                performUIUpdatesOnMain {
                    errorAlertView(error?.userInfo[NSLocalizedDescriptionKey] as! String, self)
                }
            }
        }
 
    }
}


// MARK: - OTMTabBarViewController (Configure UI)

extension OTMTabBarViewController {

    // MARK: Configure NavigationItems
    func configureNavigationItems() {
        navigationItem.title = "On The Map"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 102/255, green: 51/255, blue: 204/255, alpha: 1.0)
        
        navigationItem.rightBarButtonItems?.removeAll()
        let refreshBBItem = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(updateLocations))
        refreshBBItem.tintColor = UIColor(red: 102/255, green: 51/255, blue: 204/255, alpha: 1.0)
        
        let addBBItem = UIBarButtonItem(image: UIImage(named: "icon_pin"), style: .plain, target: self, action: #selector(addLocation))
        addBBItem.tintColor = UIColor(red: 102/255, green: 51/255, blue: 204/255, alpha: 1.0)
        
        navigationItem.rightBarButtonItems!.append(refreshBBItem)
        navigationItem.rightBarButtonItems!.append(addBBItem)
    }
}


// MARK: - OTMTabBarViewController (Alert View)

extension OTMTabBarViewController {
    
    func alertView(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "OTMInfoPostingViewController") as! OTMInfoPostingViewController
            self.selectedViewController?.present(controller, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        self.selectedViewController?.present(alertController, animated: true, completion: nil)
    }
}

