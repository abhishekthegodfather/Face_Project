//
//  Constants.swift
//  Face_Project
//
//  Created by Cubastion on 02/06/23.
//

import Foundation
import UIKit


class Constants {
    static let shared = Constants()
//    let admin_url = "http://localhost:8045/checkAdmin"
//    let getDetailsUrl = "http://localhost:8045/getEmployeeDetails"
//    let attendenceUrl = "http://localhost:8045/checkin_checkout"
//    let detectAndCompare = "http://localhost:8045/detectAndCompareFace"
//    let detectAndTechFace = "http://localhost:8045/detectAndTechFace"
//    let sendMail = "http://localhost:8045/sendMail"
//    let profilePic = "http://localhost:8045/profilePic"
    
    
    
    let base_url = "https://82f4-61-247-238-221.ngrok-free.app"
    let admin_url = "https://8d62-61-247-238-221.ngrok-free.app/checkAdmin"
    let getDetailsUrl = "https://8d62-61-247-238-221.ngrok-free.app/getEmployeeDetails"
    let attendenceUrl = "https://8d62-61-247-238-221.ngrok-free.app/checkin_checkout"
    let detectAndCompare = "https://8d62-61-247-238-221.ngrok-free.app/detectAndCompareFace"
    let detectAndTechFace = "https://8d62-61-247-238-221.ngrok-free.app/detectAndTechFace"
    let sendMail = "https://8d62-61-247-238-221.ngrok-free.app/sendMail"
    let profilePic = "https://8d62-61-247-238-221.ngrok-free.app/profilePic"

    
    func makeAlert(message: String, title: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return alert
    }
}


extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            self.append(data)
        }
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}





