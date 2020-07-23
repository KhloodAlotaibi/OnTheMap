//
//  MapLocationViewController.swift
//  OnTheMap
//
//  Created by Khlood on 7/14/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import UIKit
import MapKit

class MapLocationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var myMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myMapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPins()
    }
    
    @IBAction func addLocationButtonClicked(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        getPins()
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        API.logout { (success, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showAlert(title: "Error", message: "there is error")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    func getPins() {
        var annotations = [MKPointAnnotation] ()
        myMapView.removeAnnotations(myMapView.annotations)
        API.getAllStudentLocations { (studentsLocations, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showAlert(title: "Error", message: "There is error")
                    return
                }
                guard let locations = studentsLocations else {
                    self.showAlert(title: "Error", message: "There is error loading students locations")
                    return
                }
                for location in locations {
                    let long = CLLocationDegrees (location.longitude ?? 0)
                    let lat = CLLocationDegrees (location.latitude ?? 0)
                    let coordinate = CLLocationCoordinate2D (latitude: lat, longitude: long)
                    let mediaURL = location.mediaURL ?? ""
                    let first = location.firstName ?? ""
                    let last = location.lastName ?? ""
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    annotations.append(annotation)
                }
                self.myMapView.addAnnotations(annotations)
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
