//
//  extensionFaceController.swift
//  Face_Project
//
//  Created by Cubastion on 08/06/23.
//

import Foundation
import UIKit

extension FacePreviewViewController {
    func handleCampareFaceAPICall(emp_image: [UIImage]) {
        self.learningView.isHidden = true
        self.loadingView.isHidden = false
        self.outComeView.isHidden = true
        self.activityIndicatorView.startAnimating()
        self.loadingLabel.text = "Wait for 15 Second For Face Verification"
        self.loadingLabel.numberOfLines = 0
        
        guard let empImage = emp_image.first else {return}
        Presenter.shared.getAndPostOneImageHandler(urlString: Constants.shared.detectAndCompare, presentingViewController: self, image: empImage) { [weak self] result in
            if let result = result as? [String: Any] {
                if let statusBody = result["status_body"] as? [String: Any] {
                    if let message = statusBody["message"] as? [String : Any] {
                        if let status = message["status"] as? Bool, let responeMsg = message["message"] as? String {
                            if (status) {
                                if let emp_code = message["emp_code"] as? String {
                                    DispatchQueue.main.async {
                                        self?.checkForScreenBtwAttendenceAndAdmin(empCode: emp_code)
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self?.activityIndicatorView.stopAnimating()
                                    self?.loadingView.isHidden = true
                                    self?.learningView.isHidden = true
                                    self?.outComeView.isHidden = false
                                    self?.ErrorImageview.image = UIImage(named: "warning") ?? UIImage()
                                    self?.errorLabel.text = responeMsg
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                        self?.loadingView.isHidden = true
                                        self?.learningView.isHidden = true
                                        self?.outComeView.isHidden = true
                                        self?.errorLabel.text = ""
                                        self?.loadingLabel.text = ""
                                        self?.dismiss(animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func checkForScreenBtwAttendenceAndAdmin(empCode : String){
        if (isPhotoForAdmin == true) && (isPhotoForAttendence == false) {
            self.checkAdminAPIcall(empCode: empCode)
        }else if (isPhotoForAdmin == false) && (isPhotoForAttendence == true){
            self.prepareForPresentAttendenceVC(emp_code: empCode)
        }else{
            self.activityIndicatorView.stopAnimating()
            self.loadingView.isHidden = true
            self.learningView.isHidden = true
            self.outComeView.isHidden = true
            let alert = Constants.shared.makeAlert(message: "Cannot Navigate to any screen as no Scrren Has Been Called", title: "Navigation Error")
            self.present(alert, animated: true){
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    func prepareForPresentAttendenceVC(emp_code: String){
        prepareForAttendenceViaEmpCode(emp_code: emp_code) { [weak self] result in
            DispatchQueue.main.async {
                self?.callAttendenceVC(AttendenceDetails: result)
            }
        }
    }
    
    func callAttendenceVC(AttendenceDetails: [String]){
        self.activityIndicatorView.stopAnimating()
        self.loadingView.isHidden = true
        self.learningView.isHidden = true
        self.outComeView.isHidden = true
        guard AttendenceDetails.count == 4 else {
            print("Error: Invalid attendance details")
            return
        }
        let fname = AttendenceDetails[0]
        let lname = AttendenceDetails[1]
        let emp_code = AttendenceDetails[2]
        let message = AttendenceDetails[3]
        

        
        let storyboard = UIStoryboard(name: "AttendenceScreen", bundle: nil)
        if let attendenceVC = storyboard.instantiateViewController(withIdentifier: "AttendenceScreen") as? AttendenceViewController {
            attendenceVC.fname = fname
            attendenceVC.lname = lname
            attendenceVC.message = message
            attendenceVC.emp_code = emp_code
            attendenceVC.modalPresentationStyle = .fullScreen
            
            
            self.present(attendenceVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                    attendenceVC.dismiss(animated: false) {
                        self.resetCamera()
                        self.dismiss(animated: true)
                    }
                }
            }
        } else {
            print("Error: Unable to instantiate AttendenceViewController")
            let alert = Constants.shared.makeAlert(message: "Unable to instantiate Attendence View", title: "Navigation Error")
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func prepareForAttendenceViaEmpCode(emp_code: String, completion: @escaping ([String]) -> Void) {
        var empDetails: [String] = []
        let group = DispatchGroup()
        group.enter()
        Presenter.shared.getAndPostDataHandler(urlString: Constants.shared.getDetailsUrl, emp_code: emp_code, presentingViewController: self) { result in
            defer { group.leave() }
            if let Dresult = result as? [String: Any] {
                if let statusBody = Dresult["status_body"] as? [String: Any] {
                    if let StatusResult = statusBody["Result"] as? [String: Any] {
                        if let fname = StatusResult["first_name"] as? String, let lname = StatusResult["last_name"] as? String, let profileImage = StatusResult["profile_pic"] as? String {
                            empDetails.append(fname)
                            empDetails.append(lname)
                            empDetails.append(emp_code)
                        }
                    }
                }
            } else {
                // Handle error in getting response
                let alert = Constants.shared.makeAlert(message: "Unable to Get Details For \(emp_code) Employee", title: "API Error")
                self.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
                        alert.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        group.enter()
        Presenter.shared.getAndPostDataHandler(urlString: Constants.shared.attendenceUrl, emp_code: emp_code, presentingViewController: self) { result in
            defer { group.leave() }
            if let Aresult = result as? [String: Any] {
                if let statusBody = Aresult["status_body"] as? [String: Any] {
                    if let message = statusBody["message"] as? [String: Any] {
                        if let attendenceMessage = message["message"] as? String {
                            empDetails.append(attendenceMessage)
                        }
                    }
                }
            } else {
                // Handle error in getting response
                let alert = Constants.shared.makeAlert(message: "Unable to Put Attendence For \(emp_code) Employee", title: "API Error")
                self.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
                        alert.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(empDetails)
        }
    }
    
    
    func handleTechApiCall(emp_code: String, emp_name: String, imageArray: [UIImage]){
        self.loadingView.isHidden = true
        self.learningView.isHidden = false
        self.outComeView.isHidden = true
        self.learningProgressView.progress = 0
        self.learningLabel.text = "Learning Face"
        
        let totalTime: TimeInterval = 25.0
        let incrementInterval: TimeInterval = totalTime / 100.0
        var currentProgress: Float = 0.0
        
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: incrementInterval, repeats: true) { timer in
                currentProgress += 1.0
                self.learningProgressView.setProgress(currentProgress / 100.0, animated: true)
                if currentProgress >= 100.0 {
                    timer.invalidate()
                }
            }
        }
        
        Presenter.shared.getAndPostManyImageHandler(urlString: Constants.shared.detectAndTechFace, emp_code: emp_code, full_name: emp_name, presentingViewController: self, imageArray: imageArray) { result in
            print(result)
            if let result = result as? [String: Any] {
                if let statusBody = result["status_body"] as? [String:Any] {
                    if let message = statusBody["message"] as? [String: Any] {
                        if let statusCode = message["status"] as? Int {
                            if (statusCode == 1){
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                                    DispatchQueue.main.async {
                                        self.learningLabel.text = "Learned Face"
                                        self.dismiss(animated: true) {
                                            self.resetCamera()
                                            self.cleaningDelegateTxtField?.cleaningJobinAdmin(txtCleaning: true)
                                        }
                                    }
                                }
                            }else{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                                    DispatchQueue.main.async {
                                        self.learningLabel.text = "Learned Face"
                                        self.dismiss(animated: true) {
                                            self.resetCamera()
                                            self.cleaningDelegateTxtField?.cleaningJobinAdmin(txtCleaning: false)
                                        }
                                    }
                                }                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func showAfterTeachFaces(message: String, title: String){
        let alert = Constants.shared.makeAlert(message: message, title: title)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                alert.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func checkAdminAPIcall(empCode: String){
        self.learningView.isHidden = true
        self.loadingView.isHidden = false
        self.outComeView.isHidden = true
        self.activityIndicatorView.startAnimating()
        self.loadingLabel.text = "Wait for 15 Second For Face Verification"
        self.loadingLabel.numberOfLines = 0
        
        Presenter.shared.getAndPostDataHandler(urlString: Constants.shared.admin_url, emp_code: empCode, presentingViewController: self) { (result) in
            if let resultDict = result as? [String: Any] {
                if let statusCode = resultDict["ret_code"] as? Int{
                    if let statusMsg = resultDict["status_body"] as? [String : Any] {
                        if let msg = statusMsg["message"] as? [String : Any] {
                            if let currStatus = msg["status"] as? Bool, let currMsg = msg["Result"] as? String{
                                if (currStatus == true){
                                    DispatchQueue.main.async {
                                        self.activityIndicatorView.stopAnimating()
                                        self.loadingView.isHidden = true
                                        self.learningView.isHidden = true
                                        self.outComeView.isHidden = true
                                        self.loadingLabel.text = ""
                                        
                                        let adminVC = UIStoryboard(name: "AdminStoryBoard", bundle: nil).instantiateViewController(withIdentifier: "adminVC") as? AdminViewController
                                        adminVC?.modalPresentationStyle = .fullScreen
                                        self.present(adminVC ?? UIViewController(), animated: true)
                                        
                                    }
                                }else{
                                    if (currMsg == "Not an Admin"){
                                        DispatchQueue.main.async {
                                            self.loadingView.isHidden = true
                                            self.learningView.isHidden = true
                                            self.outComeView.isHidden = false
                                            self.ErrorImageview.image = UIImage(named: "warning") ?? UIImage()
                                            self.errorLabel.text = currMsg
                                            self.loadingLabel.text = ""
                                            DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                                                self.loadingView.isHidden = true
                                                self.learningView.isHidden = true
                                                self.outComeView.isHidden = true
                                                self.errorLabel.text = ""
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                    }else if(currMsg == "Failed to get user from DB"){
                                        DispatchQueue.main.async {
                                            self.loadingView.isHidden = true
                                            self.learningView.isHidden = true
                                            self.outComeView.isHidden = false
                                            self.ErrorImageview.image = UIImage(named: "warning") ?? UIImage()
                                            self.errorLabel.text = currMsg
                                            self.loadingLabel.text = ""
                                            DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                                                self.loadingView.isHidden = true
                                                self.learningView.isHidden = true
                                                self.outComeView.isHidden = true
                                                self.errorLabel.text = ""
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else {
                    if let errorMsg = resultDict["error"] as? String {
                        DispatchQueue.main.async {
                            let alert = Constants.shared.makeAlert(message: errorMsg, title: "Error")
                            self.present(alert, animated: true) {
                                DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                                    alert.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

