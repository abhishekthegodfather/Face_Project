//
//  NetworkHandler.swift
//  Face_Project
//
//  Created by Cubastion on 02/06/23.
//

import Foundation
import UIKit
import Reachability

class NetworkHandler {
    static let shared = NetworkHandler()
    let reachablity = try? Reachability()
    
    func genericApiCaller(urlString: String, emp_code: String, presentingViewController: UIViewController?, completion: @escaping (Data) -> Void) {
        
        //checks the device connectivity
        if reachablity?.connection == .unavailable {
            DispatchQueue.main.async {
                let alert = Constants.shared.makeAlert(message: "No, Connection Found, Please Connect to Internet", title: "Network Error")
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(okAction)
                presentingViewController?.present(alert, animated: true)
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let requestBody: [String: Any] = [
            "employee_code": emp_code
        ]
        
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            print("JSON Data is Created")
            urlRequest.httpBody = jsonBody
        } catch {
            completion(Data())
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error as NSError?, error.domain == NSURLErrorDomain,
               error.code == NSURLErrorCannotConnectToHost, let errorDescription = error.userInfo[NSLocalizedDescriptionKey] as? String,
               errorDescription.contains("Could not connect to the server."){
                print("Error: Could not connect to the server.")
                
                DispatchQueue.main.async {
                    let alert = Constants.shared.makeAlert(message: "Could not connect to the server. Please check your internet connection and try again.", title: "Connection Error")
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    presentingViewController?.present(alert, animated: true, completion: nil)
                }
            } else if let data = data {
                completion(data)
            }
        }
        task.resume()
    }
    
    
    func genericImageArrayCaller(urlString: String, presentingViewController: UIViewController?, images: [UIImage], empCode: String, empName: String, completion: @escaping (Data) -> Void) {
        // Check device connectivity
        if reachablity?.connection == .unavailable {
            DispatchQueue.main.async {
                let alert = Constants.shared.makeAlert(message: "No connection found. Please connect to the internet.", title: "Network Error")
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(okAction)
                presentingViewController?.present(alert, animated: true)
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        var error: Error? = nil
        
        // Add emp_code and emp_name parameters
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"emp_code\"\r\n\r\n\(empCode)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"emp_name\"\r\n\r\n\(empName)\r\n".data(using: .utf8)!)
        
        for (index, image) in images.enumerated() {
            let paramName = "images"
            let fileName = "image\(index + 1).jpg"
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append(imageData)
            } else {
                print("Failed to get image data")
                return
            }
            
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    let alert = Constants.shared.makeAlert(message: "An error occurred while sending the request. Please try again.", title: "Request Error")
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    presentingViewController?.present(alert, animated: true, completion: nil)
                }
            } else if let data = data {
                completion(data)
            }
        }
        
        task.resume()
    }
    
    func genericImageCaller(urlString: String, presentingViewController: UIViewController?, withImage image: UIImage, completion: @escaping (Data) -> Void) {
        // checks the device connectivity
        if reachablity?.connection == .unavailable {
            DispatchQueue.main.async {
                let alert = Constants.shared.makeAlert(message: "No connection found. Please connect to the internet.", title: "Network Error")
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(okAction)
                presentingViewController?.present(alert, animated: true)
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()
        
        // Append image data
        httpBody.appendString("--\(boundary)\r\n")
        httpBody.appendString("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpg\"\r\n")
        httpBody.appendString("Content-Type: image/jpeg\r\n\r\n")
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            httpBody.append(imageData)
        } else {
            print("Failed to get image data")
            return
        }
        
        httpBody.appendString("\r\n--\(boundary)--\r\n")

        request.httpBody = httpBody as Data
        
        let task = URLSession.shared.uploadTask(with: request, from: nil) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    let alert = Constants.shared.makeAlert(message: "An error occurred while sending the request. Please try again.", title: "Request Error")
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    presentingViewController?.present(alert, animated: true, completion: nil)
                }
            } else if let data = data {
                completion(data)
            }
        }
        
        task.resume()
    }
    
    
    
    func sendMailApiCaller(urlString: String, emailId: String, issueDesc: String, issueTitle: String, presentingViewController: UIViewController?, compleation: @escaping(Data) -> Void){
        if reachablity?.connection == .unavailable {
            DispatchQueue.main.async {
                let alert = Constants.shared.makeAlert(message: "No connection found. Please connect to the internet.", title: "Network Error")
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(okAction)
                presentingViewController?.present(alert, animated: true)
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let requestBody: [String: Any] = [
            "emailId": emailId,
            "issue_desc" : issueDesc,
            "issue_title" : issueTitle
        ]
        
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            print("JSON Data is Created")
            urlRequest.httpBody = jsonBody
        } catch {
            compleation(Data())
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error as NSError?, error.domain == NSURLErrorDomain,
               error.code == NSURLErrorCannotConnectToHost, let errorDescription = error.userInfo[NSLocalizedDescriptionKey] as? String,
               errorDescription.contains("Could not connect to the server."){
                print("Error: Could not connect to the server.")
                
                DispatchQueue.main.async {
                    let alert = Constants.shared.makeAlert(message: "Could not connect to the server. Please check your internet connection and try again.", title: "Connection Error")
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    presentingViewController?.present(alert, animated: true, completion: nil)
                }
            } else if let data = data {
                compleation(data)
            }
        }
        task.resume()
    }
}

