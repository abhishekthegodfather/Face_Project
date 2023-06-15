//
//  Constants.swift
//  Face_Project
//
//  Created by Cubastion on 02/06/23.
//

import Foundation
import UIKit

//let base_url_dev : String = "http://localhost:8045"
let base_url_prod : String = "https://82f4-61-247-238-221.ngrok-free.app"

class Constants {
    static let shared = Constants()
//    let admin_url = "\(base_url_dev)/checkAdmin"
//    let getDetailsUrl = "\(base_url_dev)/getEmployeeDetails"
//    let attendenceUrl = "\(base_url_dev)/checkin_checkout"
//    let detectAndCompare = "\(base_url_dev)/detectAndCompareFace"
//    let detectAndTechFace = "\(base_url_dev)/detectAndTechFace"
//    let sendMail = "\(base_url_dev)/sendMail"
//    let profilePic = "\(base_url_dev)/profilePic"
    
    
    let admin_url = "\(base_url_prod)/checkAdmin"
    let getDetailsUrl = "\(base_url_prod)/getEmployeeDetails"
    let attendenceUrl = "\(base_url_prod)/checkin_checkout"
    let detectAndCompare = "\(base_url_prod)/detectAndCompareFace"
    let detectAndTechFace = "\(base_url_prod)/detectAndTechFace"
    let sendMail = "\(base_url_prod)/sendMail"
    let profilePic = "\(base_url_prod)/profilePic"

    
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





