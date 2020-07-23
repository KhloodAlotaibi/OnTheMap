//
//  API.swift
//  OnTheMap
//
//  Created by Khlood on 7/14/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import Foundation

class API {
    
    struct Student {
        static var accountKey = ""
        static var firstname = ""
        static var lastname = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case getStudentName
        case getAllStudentLocations
        case postStudentLocation
        case logout
        
        var stringValue: String {
            switch self {
            case .login, .logout:
                return Endpoints.base + "/session"
            case .getStudentName:
                return Endpoints.base + "/users/" + Student.accountKey
            case .getAllStudentLocations:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .postStudentLocation:
                return Endpoints.base + "/StudentLocation"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func login (_ username: String!, _ password: String!, completion: @escaping (Bool, Error?)-> Void) {
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username!)\", \"password\": \"\(password!)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                print("internet connection issue")
                completion(false,error)
                return
            }
            if statusCode >= 200 && statusCode < 300 {
                let range = 5..<data!.count
                let newData = data?.subdata(in: range) /* subset response data! */
                print(String(data: newData!, encoding: .utf8)!)
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(LoginResponse.self, from: newData!)
                    Student.accountKey = response.account?.key ?? ""
                    getStudentName { (success, error) in
                    }
                    completion(true, nil)
                } catch {
                    print(error)
                    completion(false,error)
                }
            } else {
            completion(false, error)
            }
        }
        task.resume()
    }
    
    class func getStudentName (completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.getStudentName.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                print("response error")
                completion(false, error)
                return
            }
            if statusCode >= 200 && statusCode < 300 {
                let range = 5..<data!.count
                let newData = data?.subdata(in: range)
                print(String(data: newData!, encoding: .utf8)!)
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(StudentName.self, from: newData!)
                    Student.firstname = response.firstname ?? ""
                    Student.lastname = response.lastname ?? ""
                    completion(true, nil)
                } catch {
                    completion(false, error)
                }
            } else {
                completion(false, error)
            }
        }
        task.resume()
    }
    
    class func getAllStudentLocations(completion: @escaping ([StudentLocation]?, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.getAllStudentLocations.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                print("response error")
                completion(nil, error)
                return
            }
            if statusCode >= 200 && statusCode < 300 {
                print(String(data: data!, encoding: .utf8)!)
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(StudentLocationResult.self, from: data!)
                    completion(response.results, nil)
                } catch {
                    print(error)
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    class func postStudentLocation (_ location: StudentLocation, completion: @escaping (Bool, Error?)-> Void) {
        var request = URLRequest(url: Endpoints.postStudentLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Student.accountKey)\", \"firstName\": \"\(Student.firstname)\", \"lastName\": \"\(Student.lastname)\",\"mapString\": \"\(location.mapString!)\", \"mediaURL\": \"\(location.mediaURL!)\",\"latitude\": \(location.latitude!), \"longitude\": \(location.longitude!)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion (false, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(false,error)
                return
            }
            if statusCode >= 200 && statusCode < 300 {
                print(String(data: data!, encoding: .utf8)!)
                do { 
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(PostLocationResponse.self, from: data!)
                    completion(true, nil)
                } catch {
                    print(error)
                    completion(false,error)
                }
            } else {
                completion(false, error)
            }
        }
        task.resume()
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print(" logging out issue")
                completion(false, error)
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            Student.accountKey = ""
            completion(true, nil)
        }
        task.resume()
    }
}
