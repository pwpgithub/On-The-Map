//
//  OTMTableViewController.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/7/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit

// MARK: - OTMTableViewController: UIViewController

class OTMTableViewController: UIViewController {
    
    // MARK: Propeerties
    
    //var locations: [PARSEUserLocation] = [PARSEUserLocation]()
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        prepareUI()
        loadTableLocations()
    }

    
    // MARK: Actions
    
    func loadTableLocations() {
        
        self.setUIWhileLoading(true)
        
        PARSEClient.sharedInstance().getAllLocations { (success, locations, error) in
            
            if let error = error {
                performUIUpdatesOnMain {
                    self.setUIWhileLoading(false)
                    errorAlertView(error.userInfo[NSLocalizedDescriptionKey] as! String, self)
                }
            } else {
                if locations != nil  {
                    performUIUpdatesOnMain {
                        self.tableView.reloadData()
                        self.setUIWhileLoading(false)
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.setUIWhileLoading(false)
                        errorAlertView("No Locations were returned", self)
                    }
                }
            }
        }
    }
}


// MARK: - OTMTableViewController (UI)

extension OTMTableViewController {
    
    func prepareUI() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func setUIWhileLoading(_ isloading: Bool) {
        
        isloading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        
        dimView.isHidden = !isloading
        activityIndicatorView.isHidden = !isloading
    }
}


// MARK: - OTMTableViewController: UITableViewDelegate, UITableViewDataSource

extension OTMTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let location = LocationStore.sharedInstance().allLocations[indexPath.row]
        if let mediaURL = location.mediaURL, !mediaURL.isEmpty {
            let url = URL(string: mediaURL)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            errorAlertView("Cannot open URL", self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationStore.sharedInstance().allLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseIdentifier = "Cell"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier)
        
        configureTableCell(cell!, indexPath)
        return cell!
    }
    
}


// MARK: - OTMTableViewController (Helpers)

extension OTMTableViewController {
    
    func configureTableCell(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        
        let location = LocationStore.sharedInstance().allLocations[indexPath.row]
        
        if let mediaURL = location.mediaURL {
            let cellIndex = Int(indexPath.row)
            
            if cellIndex % 2 != 0 {
                cell.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 255/255, alpha: 0.65)
            } else {
                cell.backgroundColor = .white
            }
            
            cell.textLabel?.text = "\(location.firstName!) \(location.lastName!)"
            cell.detailTextLabel?.text = mediaURL
            cell.textLabel?.textColor = UIColor(red: 102/255, green: 51/255, blue: 204/255, alpha: 1.0)
            cell.imageView?.image = UIImage(named: "icon_pin")
        }
    }
}
