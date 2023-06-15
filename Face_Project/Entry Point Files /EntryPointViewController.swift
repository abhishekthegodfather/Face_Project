//
//  ViewController.swift
//  Face_Project
//
//  Created by Abhishek772 on 02/06/23.
//

import UIKit
import DropDown

class EntryPointViewController: UIViewController {

    @IBOutlet weak var adminAcceesBtn: UIButton!
    @IBOutlet weak var markAttendence: UIButton!
    @IBOutlet weak var raiseIssue: UIButton!
    @IBOutlet weak var issueView: UIView!
    @IBOutlet weak var issueTextField: UITextView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var selectIssueBtn: UIButton!
    @IBOutlet weak var emailIdTextField: UITextField!
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.issueView.isHidden = true
        self.cancelBtn.layer.cornerRadius = 20
        self.sendbtn.layer.cornerRadius = 20
        adminAcceesBtn.addTarget(self, action: #selector(adminAcceesAction(_ :)), for: .touchUpInside)
        markAttendence.addTarget(self, action: #selector(AttendenceAcceesAction(_ :)), for: .touchUpInside)
        raiseIssue.addTarget(self, action: #selector(raiseIssueAction(_ :)), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelAction(_ :)), for: .touchUpInside)
        sendbtn.addTarget(self, action: #selector(sendBtnAction(_ :)), for: .touchUpInside)
        selectIssueBtn.addTarget(self, action: #selector(selectIssueBtnAction(_ :)), for: .touchUpInside)
        self.logoImage.layer.cornerRadius = 15
        self.markAttendence.layer.cornerRadius = 15
        self.issueTextField.layer.cornerRadius = 10
        self.issueTextField.layer.borderWidth = 1
        self.issueTextField.layer.borderColor = UIColor.black.cgColor
        self.selectIssueBtn.layer.cornerRadius = 10

    }
    
    func clearningIssueJob(){
        self.issueTextField.text = "Write Issue"
        self.emailIdTextField.text = ""
        self.issueView.isHidden = true
        let itemString = "Select Issue"
        let font = UIFont(name: "GillSans", size: 18) ?? UIFont.systemFont(ofSize: 18)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
        ]
        let attributedString = NSAttributedString(string: itemString, attributes: attributes)
        self.selectIssueBtn.setAttributedTitle(attributedString, for:  .normal)
    }
    
    @objc func cancelAction(_ sender: UIButton){
        self.clearningIssueJob()
    }
    
    @objc func sendBtnAction(_ sender: UIButton){
        guard let btnTitle = self.selectIssueBtn.currentAttributedTitle?.string else {return}
        guard let issueText = self.issueTextField.text else {return}
        guard let emailTxt = self.emailIdTextField.text else {return}
        
        if (btnTitle != "Select Issue"){
            if (issueText != ""){
                if (emailTxt != ""){
                    self.prepForMailAPI(empEmailId: emailTxt, issueTitle: btnTitle, issueDesc: issueText)
                }else{
                    let alert = Constants.shared.makeAlert(message: "Blank Email Field", title: "Error")
                    self.present(alert, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                            alert.dismiss(animated: true)
                        }
                    }
                }
            }else{
                let alert = Constants.shared.makeAlert(message: "Blank Issue Field", title: "Error")
                self.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                        alert.dismiss(animated: true)
                    }
                }
            }
        }else{
            let alert = Constants.shared.makeAlert(message: "Choose Issue", title: "Error")
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                    alert.dismiss(animated: true)
                }
            }
        }
    }
    
    func prepForMailAPI(empEmailId: String, issueTitle: String, issueDesc: String){
        Presenter.shared.postMailAPICaller(urlString: Constants.shared.sendMail, empIssueTitle: issueTitle, empIssueDesc: issueDesc, empEmailId: empEmailId, presentingViewController: self) { [weak self] result in
            if let resultResponse = result as? [String: Any]{
                if let resultStatus = resultResponse["status"] as? Bool, let resultMessage = resultResponse["message"] as? String {
                    if resultStatus == true {
                        DispatchQueue.main.async {
                            let alert = Constants.shared.makeAlert(message: "Sucessfully Send Mail to HR Department", title: "Sucess")
                            self?.present(alert, animated: true) {
                                DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                                    self?.clearningIssueJob()
                                    alert.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            let alert = Constants.shared.makeAlert(message: "Failed to Send Mail to HR Department, Check mail Id Again or Do After Sometimes", title: "Failed")
                            self?.present(alert, animated: true) {
                                DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                                    alert.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func selectIssueBtnAction(_ sender: UIButton){
        dropDown.anchorView = self.selectIssueBtn
        dropDown.direction = .bottom
        dropDown.dataSource = ["Unable to Mark Attendence", "Matching with Different Person", "Camera Problems", "UI Realted problems", "Face not Found problem", "Access Control Problems", "DB Problems", "Others"]
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            DispatchQueue.main.async {
                let itemString = item
                let font = UIFont(name: "GillSans", size: 18) ?? UIFont.systemFont(ofSize: 18)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                ]
                let attributedString = NSAttributedString(string: itemString, attributes: attributes)
                self?.selectIssueBtn.setAttributedTitle(attributedString, for:  .normal)
            }
        }
        dropDown.show()
    }
    
    @objc func adminAcceesAction(_ sender: UIButton){
        let facePreviewvc = UIStoryboard(name: "TechFace", bundle: nil).instantiateViewController(withIdentifier: "TeachFaceViewController") as? FacePreviewViewController
        facePreviewvc?.modalPresentationStyle = .fullScreen
        facePreviewvc?.isPhotoForAttendence = false
        facePreviewvc?.isPhotoForTech = false
        facePreviewvc?.isPhotoForAdmin = true
        facePreviewvc?.numPhotos = 1
        self.present(facePreviewvc ?? UIViewController(), animated: true)
    }
    
    @objc func raiseIssueAction(_ sender: UIButton){
        self.issueView.isHidden = false

    }
    
    
    @objc func AttendenceAcceesAction(_ sender: UIButton) {
        let facePreviewvc = UIStoryboard(name: "TechFace", bundle: nil).instantiateViewController(withIdentifier: "TeachFaceViewController") as? FacePreviewViewController
        facePreviewvc?.modalPresentationStyle = .fullScreen
        facePreviewvc?.isPhotoForAttendence = true
        facePreviewvc?.isPhotoForTech = false
        facePreviewvc?.isPhotoForAdmin = false
        facePreviewvc?.numPhotos = 1
        self.present(facePreviewvc ?? UIViewController(), animated: true)
    }
    
}





