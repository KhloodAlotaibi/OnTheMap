//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Khlood on 7/14/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import UIKit
import CoreLocation

class PostLocationViewController: UIViewController {

    @IBOutlet var myAddressTextField: UITextField!
    @IBOutlet var myURLText: UITextField!
    @IBOutlet var LocationMapImage: UIImageView!
    @IBOutlet var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var findLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationMapImage.image = UIImage(named: "location")
    }
    
    @IBAction func findLocationButtonClicked(_ sender: Any) {
        setUI(true)
        if (myAddressTextField.text!.isEmpty) || (myURLText.text!.isEmpty) {
            setUI(false)
            showAlert(title: "Error", message: "Both address and url are required")
        } else {
            let studentLocation = StudentLocation(mapString: myAddressTextField.text!, mediaURL: myURLText.text!)
            geocodeCoordinates(studentLocation)
        }
    }
    
    private func geocodeCoordinates(_ studentLocation: StudentLocation) {
        self.setUI(true)
        CLGeocoder().geocodeAddressString(studentLocation.mapString!) { (placeMarks, error) in
            self.setUI(false)
            guard let firstLocation = placeMarks?.first?.location else {
                self.showAlert(title: "Error", message: "Invalid address")
                return }
            var location = studentLocation
            location.latitude = firstLocation.coordinate.latitude
            location.longitude = firstLocation.coordinate.longitude
            self.performSegue(withIdentifier: "ConfirmLocation", sender: location)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmLocation" {
            let nextController = segue.destination as? ConfirmLocationOnMapViewController
            nextController?.location = (sender as! StudentLocation)
        }
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUI(_ postingInProgress: Bool) {
        if postingInProgress {
            myActivityIndicator.startAnimating()
        } else {
            myActivityIndicator.stopAnimating()
        }
        myAddressTextField.isEnabled = !postingInProgress
        myURLText.isEnabled = !postingInProgress
        findLocationButton.isEnabled = !postingInProgress
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
