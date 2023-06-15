//
//  AdminViewController.swift
//  Face_Project
//
//  Created by Cubastion on 02/06/23.
//

import UIKit



class AdminViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var empCodeTxtField: UITextField!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var detailsview: UIView!
    @IBOutlet weak var heightOfStackView: NSLayoutConstraint!
    @IBOutlet weak var nameStackView: UIStackView!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        proceedBtn.addTarget(self, action: #selector(proceedBtnAction(_ :)), for: .touchUpInside)
        exitBtn.addTarget(self, action: #selector(exitBtnAction(_ :)), for: .touchUpInside)
        self.nameLabel.isHidden = true
        self.nameTxtField.isHidden = true
        self.empCodeTxtField.delegate = self
        self.heightOfStackView.constant = 100
        self.nameStackView.isHidden = true
        self.detailsview.layer.cornerRadius = 10
        self.detailsview.layer.borderWidth = 1.5
        self.detailsview.layer.borderColor = UIColor.black.cgColor
        self.hideKeyboardWhenTappedAround() 
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = self.empCodeTxtField.text else {
            return true
        }
        let updatedEmpText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if updatedEmpText.count == 8 {
            self.handelDetaialsApiCall(updatedEmpText)
        }else if updatedEmpText.count > 8 {
            self.heightOfStackView.constant = 100
            self.nameTxtField.isHidden = true
            self.nameLabel.isHidden = true
            self.nameStackView.isHidden = true
            self.empCodeTxtField.text = ""
            let alert = Constants.shared.makeAlert(message: "Employee Code Cannot be more than 8", title: "Employee Code Error")
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }else if updatedEmpText.count == 0 {
            self.heightOfStackView.constant = 100
            self.nameTxtField.isHidden = true
            self.nameLabel.isHidden = true
            self.nameStackView.isHidden = true
            self.empCodeTxtField.text = ""
        }
    
        return true
    }
    
    func handelDetaialsApiCall(_ emp_code: String){
        Presenter.shared.getAndPostDataHandler(urlString: Constants.shared.getDetailsUrl, emp_code: emp_code, presentingViewController: self) {[weak self] result in
            if let Dresult = result as? [String: Any]{
                if let statusBody = Dresult["status_body"] as? [String: Any] {
                    if let statusCode = statusBody["status"] as? Int, let StatusResult = statusBody["Result"] as? [String : Any] {
                        if let fname = StatusResult["first_name"] as? String, let lname = StatusResult["last_name"] as? String {
                            DispatchQueue.main.async {
                                self?.bringNameField(statusCode: statusCode, fname: fname, lname: lname)
                            }
                        }
                    }
                }
            }else{
                let alert = Constants.shared.makeAlert(message: "Error in getting response", title: "API Error")
                self?.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func bringNameField(statusCode: Int, fname: String, lname: String){
        if (statusCode == 1) && (fname != "") && (lname != "") {
            let resultName = fname + " " + lname
            self.nameTxtField.text = resultName
            self.heightOfStackView.constant = 200
            self.nameTxtField.isHidden = false
            self.nameLabel.isHidden = false
            self.nameStackView.isHidden = false
        }else{
            let alert = Constants.shared.makeAlert(message: "Name is black for this Employee ID, Contact Backend Team", title: "API Error")
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    
    
    
    @objc func proceedBtnAction(_ sender: UIButton){
        guard let txtEmp = empCodeTxtField.text else {
            return
        }
        
        if (txtEmp != "") {
            guard let txtName = nameTxtField.text else {
                return
            }
            self.handleFaceTechings(txtEmp, txtName)
        }else{
            let alert = Constants.shared.makeAlert(message: "TXT Fields Cannot Be Empty", title: "Blank Error")
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func handleFaceTechings(_ empField: String, _ empName: String) {
        let facePreviewVC = UIStoryboard(name: "TechFace", bundle: nil).instantiateViewController(withIdentifier: "TeachFaceViewController") as? FacePreviewViewController
//        facePreviewVC?.resetCamera()
        facePreviewVC?.numPhotos = 10
        facePreviewVC?.isPhotoForTech = true
        facePreviewVC?.isPhotoForAttendence = false
        facePreviewVC?.isPhotoForAdmin = false
        facePreviewVC?.modalPresentationStyle = .fullScreen
        facePreviewVC?.empCode = empField
        facePreviewVC?.empName = empName
        facePreviewVC?.cleaningDelegateTxtField = self
        self.present(facePreviewVC ?? UIViewController(), animated: true, completion: nil)
    }
    
    
    @objc func exitBtnAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

extension AdminViewController : cleanAdminTxtFieldAfterTeach {
    func cleaningJobinAdmin(txtCleaning: Bool) {
        if (txtCleaning == true) {
            let alert = Constants.shared.makeAlert(message: "Sucessfully Learned Face", title: "Learning Face Result")
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                    self.heightOfStackView.constant = 100
                    self.nameTxtField.isHidden = true
                    self.nameLabel.isHidden = true
                    self.nameStackView.isHidden = true
                    self.empCodeTxtField.text = ""
                    alert.dismiss(animated: true)
                }
            }
        }else if (txtCleaning == false){
            let alert = Constants.shared.makeAlert(message: "Failed to Learned Face", title: "Learning Face Result")
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                    alert.dismiss(animated: true)
                }
            }
        }
    }

}

