//
//  AttendenceViewController.swift
//  Face_Project
//
//  Created by Cubastion on 05/06/23.
//

import UIKit
import Kingfisher

class AttendenceViewController: UIViewController {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var greetingMsgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var mainElevatedView: UIView!
    @IBOutlet weak var subMainElevatedView: UIView!
    @IBOutlet weak var greetStackview: UIStackView!
    
    
    
    var teachFaceViewController: FacePreviewViewController?
    var fname : String?
    var lname : String?
    var message : String?
    var cache = ImageCache.default
    var emp_code: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepAttendenceScreen()
        prepareLabelsForShow()
        prepForRetriveImage()
    }
    
    
    func prepForRetriveImage(){
        Presenter.shared.getAndPostDataHandler(urlString: Constants.shared.profilePic, emp_code: emp_code ?? "", presentingViewController: self) { [self] result in
            if let resultImageData = result as? [String : Any] {
                if let base64_image = resultImageData["image_data"] as? String {
                    guard let imageData = Data(base64Encoded: base64_image) else {
                        return
                    }
                    self.prepareProfileImage(profileImageData: imageData, emp_code: emp_code ?? "")
                    
                }
            }
        }
    }
    
    
    func prepAttendenceScreen(){
        self.mainElevatedView.layer.cornerRadius = 50
        self.mainElevatedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainElevatedView.layer.masksToBounds = true
        self.mainElevatedView.layer.borderWidth = 1
        self.mainElevatedView.layer.borderColor = UIColor.black.cgColor
        
        self.greetStackview.layer.cornerRadius = self.greetStackview.frame.size.width/2 * 0.15
        self.greetStackview.layer.borderWidth = 1
        self.greetStackview.layer.borderColor = UIColor.black.cgColor
        
        self.subMainElevatedView.layer.cornerRadius = self.subMainElevatedView.frame.size.width/2 * 0.15
        self.subMainElevatedView.layer.borderWidth = 1
        self.subMainElevatedView.layer.borderColor = UIColor.black.cgColor
    }
    
    
    func prepareProfileImage(profileImageData: Data, emp_code: String) {
        if let profileImage = UIImage(data: profileImageData) {
            cache.storeToDisk(profileImageData, forKey: emp_code)
            DispatchQueue.main.async {
                print("Image downloaded")
                self.profileImage.image = profileImage
            }
        } else {
            let alert = UIAlertController(title: "Invalid Image Data", message: "Image cannot be loaded", preferredStyle: .alert)
            present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func retrieveFromCache(emp_code: String, imageData: Data) {
        cache.retrieveImage(forKey: emp_code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let cacheResult):
                switch cacheResult {
                case .none:
                    print("Image is not in cache")
                    self.removeFromCache(emp_code: emp_code)
                    DispatchQueue.main.async {
                        self.prepareProfileImage(profileImageData: imageData, emp_code: emp_code)
                    }
                case .memory(let image):
                    if let proImg = self.convertToUIImage(kfImage: image ?? KFCrossPlatformImage()) {
                        DispatchQueue.main.async {
                            print("Image is From Cache (Memory)")
                            self.profileImage.image = proImg
                        }
                    }
                case .disk(let image):
                    if let proImg = self.convertToUIImage(kfImage: image ?? KFCrossPlatformImage()) {
                        DispatchQueue.main.async {
                            print("Image is From Cache (Disk)")
                            self.profileImage.image = proImg
                        }
                    }
                }
            case .failure(let error):
                print("Error retrieving image from cache: \(error)")
                DispatchQueue.main.async {
                    self.prepareProfileImage(profileImageData: imageData, emp_code: emp_code)
                }
            }
        }
    }
    
    func removeFromCache(emp_code: String) {
        cache.removeImage(forKey: emp_code)
        print("Image removed from cache")
    }
    
    
    func convertToUIImage(kfImage: KFCrossPlatformImage?) -> UIImage? {
        return kfImage
    }
    
    func prepareLabelsForShow(){
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let localTime = formatter.string(from: currentDateTime)
        self.nameLabel.text = (fname ?? "") + " " + (lname ?? "")
        self.checkLabel.text = message
        
        if (message == "Checked in successfully"){
            self.greetingLabel.text = "Welcome"
            self.greetingMsgLabel.text = "Welcome, Have a Great Day!"
            self.timeLabel.text = localTime
            
        }else if (message == "Checked out successfully"){
            self.greetingLabel.text = "Good Bye"
            self.greetingMsgLabel.text = "Thank you, Have a Wonderful Evening!"
            self.timeLabel.text = localTime
        }
        
    }
    
}
