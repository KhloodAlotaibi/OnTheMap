//
//  ConfirmLocationOnMapViewController.swift
//  OnTheMap
//
//  Created by Khlood on 7/15/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import UIKit
import MapKit

class ConfirmLocationOnMapViewController: UIViewController {
    
    @IBOutlet var myMapView: MKMapView!
    var location: StudentLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }
    
    func setupMap() {
        guard let location = location else { return }
        let lat = CLLocationDegrees(location.latitude!)
        let lon = CLLocationDegrees(location.longitude!)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location.mapString
        myMapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        myMapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen), app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func finishButtonClicked(_ sender: Any) {
        API.postStudentLocation(location!) { (success, error)  in 
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showAlert(title: "Error", message: "Couldn't add the location")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
