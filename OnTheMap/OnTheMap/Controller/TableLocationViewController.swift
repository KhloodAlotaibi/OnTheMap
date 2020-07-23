//
//  TableLocationViewController.swift
//  OnTheMap
//
//  Created by Khlood on 7/14/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import UIKit

class TableLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var myTableView: UITableView!
    var myStudentsLocations = [StudentLocation]()
    
    override func viewWillAppear(_ animated: Bool) {
        getList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myStudentsLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
        cell.textLabel?.text = "\(myStudentsLocations[indexPath.row].firstName ?? "") " + "\(myStudentsLocations[indexPath.row].lastName ?? "")"
        cell.detailTextLabel?.text = "\(myStudentsLocations[indexPath.row].mediaURL ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: "\(myStudentsLocations[indexPath.row].mediaURL ?? "")") {
            UIApplication.shared.open(url)
        }
    }
    
    func getList() {
        API.getAllStudentLocations { (Locations, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showAlert(title: "Error", message: "There is error loading locations")
                    return
                }
                self.myStudentsLocations = Locations ?? []
                self.myTableView.reloadData()
            }
        }
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        getList()
    }
    
    @IBAction func addLocationButtonClicked(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        API.logout { (success, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showAlert(title: "Error", message: "There is error")
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
