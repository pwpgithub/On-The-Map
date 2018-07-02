//
//  OTMInfoPostingViewController.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/13/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import MapKit

// MARK: - OTMInfoPostingViewController: UIViewController

class OTMInfoPostingViewController: UIViewController {
    
    // MARK: Properties
    var Latitude: Double!
    var longitude: Double!
    var mapString: String!
    
    
    var userLocation: PARSEUserLocation = PARSEUserLocation(dictionary: [:])
    var isKeyboardOnScreen: Bool = false
    
    // MARK: Outlets
    
    // LocationView
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    // webLinkView
    @IBOutlet weak var webLinkView: UIView!
    @IBOutlet weak var webLinkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeKeyboardNotification()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        prepareUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeKeyboardNotification()
    }
    
    
    // MARK: Actions

    // Cancel
    @IBAction func cancelBBItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Tap Background
    @IBAction func backgroundTapped(_ sender: Any) {
        //resetViewPosition()
        view.endEditing(true)
    }
    
    // TextField resign first responder
    @IBAction func webLinkViewTapped(_ sender: Any) {
        textFieldResignIfFirstResponder(self.webLinkTextField)
    }
    
    // Find On The Map
    @IBAction func findOnTheMapButtonPressed(_ sender: Any) {
        isGeocodingView(true)
        
        if let addressString = self.locationTextView.text {
            self.mapString = addressString
            
            let geoCoder = CLGeocoder()
            
            isGeocodingView(geoCoder.isGeocoding)
            geoCoder.geocodeAddressString(addressString, completionHandler: { (placeMarkArray, error) in
                
                guard let placeMarkArray = placeMarkArray else {
                    if let code = (error as NSError?)?.code, code == 2 {
                        performUIUpdatesOnMain {
                            self.isGeocodingView(false)
                            errorAlertView("Offline", self)
                        }
                    }else if let code = (error as NSError?)?.code, code == 8 {
                        performUIUpdatesOnMain {
                            self.isGeocodingView(false)
                            errorAlertView("Please enter a valid location!", self)
                        }
                    }
                    return
                }
                
                for placeMark in placeMarkArray {
                    if let lat = (placeMark.location?.coordinate.latitude),
                        let lon = (placeMark.location?.coordinate.longitude) {
                        print("Lat & Lon: \(lat), \(lon)")
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = (placeMark.location?.coordinate)!
                        let center = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lon))
                        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.10, 0.10))
                        self.Latitude = lat
                        self.longitude = lon
                        performUIUpdatesOnMain {
                            self.mapView.addAnnotation(annotation)
                            self.mapView.setRegion(region, animated: true)
                            self.view.endEditing(true)
                            self.locationViewIsHidden(true)
                        }
                    }
                }
            })
        }
    }
    
    
    // Submit Location
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        if let mediaURL = self.webLinkTextField.text, !mediaURL.isEmpty {
            if let accountKey = UDACITYClient.sharedInstance().userID,
                let mapString = self.mapString,
                let lat = self.Latitude,
                let lon = self.longitude,
                let firstName = UDACITYClient.sharedInstance().firstName,
                let lastName = UDACITYClient.sharedInstance().lastName {
            
                var userLocation = PARSEUserLocation(dictionary: [:])
                userLocation.firstName = firstName
                userLocation.lastName = lastName
                userLocation.latitude = lat
                userLocation.longitude = lon
                userLocation.mapString = mapString
                userLocation.mediaURL = mediaURL
                userLocation.uniqueKey = accountKey
            
                // If there is location
                PARSEClient.sharedInstance().getUserLocation(accountKey, completionHanderForGetUserLocation: { (success, locations, error) in
                
                    guard error == nil else {
                        performUIUpdatesOnMain {
                            errorAlertView(error!.userInfo[NSLocalizedDescriptionKey] as! String, self)
                        }
                        return
                    }
                
                    if  let locations = locations, !locations.isEmpty {
                        userLocation.objectId = locations.first?.objectId
                       
                        // Update Location
                        PARSEClient.sharedInstance().updateUserLocation(userLocation, completionHandlerForUpdateUserLocation: { (success, updatedAt, error) in
                            if success {
                                performUIUpdatesOnMain {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            } else {
                                performUIUpdatesOnMain {
                                    errorAlertView(error?.userInfo[NSLocalizedDescriptionKey] as! String, self)
                                }
                            }
                        })
                    } else {
                        PARSEClient.sharedInstance().createUserLocation(userLocation, completionHandlerForCreateUserLocation: { (success, result, error) in
                            if success {
                                performUIUpdatesOnMain {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            } else {
                                performUIUpdatesOnMain {
                                    errorAlertView(error?.userInfo[NSLocalizedDescriptionKey] as! String, self)
                                }
                            }
                        })
                    }
                })
            }
        } else if (self.webLinkTextField.text?.isEmpty)! {
            performUIUpdatesOnMain {
                errorAlertView("Weblink cannot be empty\nPlease Enter Your Web Address!", self)
            }
        }
    }
}


// MARK: - OTMInfoPostingViewController (UI)

extension OTMInfoPostingViewController {
    
    func prepareUI() {
        self.mapView.isZoomEnabled = true
        self.mapView.isPitchEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.isScrollEnabled = true
        self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.locationView.isHidden = false
        self.webLinkView.isHidden = !self.locationView.isHidden
        isGeocodingView(false)
    }
    
    func isGeocodingView(_ isGeocoding: Bool) {
        self.dimView.isHidden = !isGeocoding
        self.activityIndicatorView.isHidden = !isGeocoding
        self.view.endEditing(!isGeocoding)
        
        isGeocoding ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }
    
    
    func locationViewIsHidden (_ isHiden: Bool) {
        self.locationView.isHidden = isHiden
        self.webLinkView.isHidden = !self.locationView.isHidden
    }
}


// MARK: - OTMInfoPostingViewController: UITextFieldDelegate (for weblink)

extension OTMInfoPostingViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            errorAlertView("Please Enter Your Web Address!", self)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text?.isEmpty)! {
            errorAlertView("Please Enter Your Web Address!", self)
        }
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        return true
    }
    
    func textFieldResignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            isKeyboardOnScreen = false
            view.frame.origin.y = 0
            textField.resignFirstResponder()
        }
    }
}


// MARK: - OTMInfoPostingViewController: UITextViewDelegate (for location)

extension OTMInfoPostingViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter Your Location!"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var newText = textView.text as NSString
        newText = newText.replacingCharacters(in: range, with: text) as NSString
        
        return true
    }
}


// MARK: - OTMInfoPostingViewController: MKMapViewDelegate

extension OTMInfoPostingViewController: MKMapViewDelegate {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        self.isGeocodingView(false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            if #available(iOS 9.0, *) {
                pinView?.pinTintColor = .red
            } else {
                // Fallback on earlier versions
            }
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
}


// MARK: - OTMInfoPostingViewController: (configure keyboard position)

extension OTMInfoPostingViewController {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !isKeyboardOnScreen && !self.locationView.isHidden {
            view.frame.origin.y -= keyboardHeight(notification) / 2
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if isKeyboardOnScreen && !self.locationView.isHidden {
            view.frame.origin.y += keyboardHeight(notification) / 2
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        isKeyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        view.frame.origin.y = 0
        isKeyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

// MARK: - OTMInfoPostingViewController (Notifications)

extension OTMInfoPostingViewController {
    
    func unsubscribeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
}
