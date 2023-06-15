//
//  TeachFaceViewController.swift
//  Face_Project
//
//  Created by Cubastion on 05/06/23.
//

import UIKit
import AVFoundation

protocol cleanAdminTxtFieldAfterTeach{
    func cleaningJobinAdmin(txtCleaning: Bool)
}


class FacePreviewViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession?
    var captureOutput: AVCapturePhotoOutput?
    var capturedPhotos: [UIImage] = []
    var numPhotos: Int?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var isPhotoForAttendence : Bool?
    var isPhotoForTech : Bool?
    var isPhotoForAdmin : Bool?
    var cleaningDelegateTxtField : cleanAdminTxtFieldAfterTeach?
    
    
    
    @IBOutlet weak var learningView: UIView!
    @IBOutlet weak var outComeView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var ErrorImageview: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var learningProgressView: UIProgressView!
    @IBOutlet weak var learningLabel: UILabel!
    

    var empName : String?
    var empCode : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.learningView.isHidden = true
        self.outComeView.isHidden = true
        self.loadingView.isHidden = true
        setupCamera()
//        capturedPhotos = [
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//            UIImage(named: "test1") ?? UIImage(),
//        ]
//
//        if isPhotoForAdmin == true || isPhotoForAttendence == true{
//            handleCampareFaceAPICall(emp_image: [UIImage(named: "test1") ?? UIImage()])
//        }else if isPhotoForTech == true{
//            handleTechApiCall(emp_code: empCode ?? "22100018", emp_name: empName ?? "Abhishek Biswas", imageArray: capturedPhotos)
//        }
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCapturing()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: captureDevice),
              let captureSession = captureSession,
              captureSession.canAddInput(input) else {
            print("Failed to access the camera.")
            return
        }
        
        captureSession.addInput(input)
        
        captureOutput = AVCapturePhotoOutput()
        
        if let captureOutput = captureOutput, captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                self.previewLayer?.videoGravity = .resizeAspectFill
                self.previewLayer?.frame = self.view.bounds
                
                if let previewLayer = self.previewLayer {
                    self.view.layer.insertSublayer(previewLayer, at: 0)
                }
                
                self.captureSession?.startRunning()
            }
        }
    }

    
    func capturePhoto() {
        guard captureOutput != nil else {
            print("Camera is not set up properly.")
            return
        }
        
        captureNextPhoto(withDelay: 0)
    }
    
    func captureNextPhoto(withDelay delay: Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){ [weak self] in
            guard let self = self else {return}
            let settings = AVCapturePhotoSettings()
//            settings.isHighResolutionPhotoEnabled = true
            self.captureOutput?.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Failed to capture photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) else {
            print("Failed to convert photo data to image.")
            return
        }
        
        if let pngData = capturedImage.pngData() {
            let pngImage = UIImage(data: pngData)
            self.capturedPhotos.append(pngImage ?? UIImage())
        }
        
        let delay: Double = 0
        
        if capturedPhotos.count < numPhotos ?? 1 {
            captureNextPhoto(withDelay: delay)
        } else {
            processCapturedPhotos(captureImage: capturedPhotos)
        }
    }
    
    func processCapturedPhotos(captureImage:[UIImage]) {
        print(captureImage)
        guard let isPhotoForTech = self.isPhotoForTech else {return}
        guard let isPhotoForAdmin = self.isPhotoForAdmin else {return}
        guard let isPhotoForAttendence = self.isPhotoForAttendence else {return}
       
    
        if (isPhotoForTech == true) && (isPhotoForAdmin == false) && (isPhotoForAttendence == false) {
            handleTechApiCall(emp_code: empCode ?? "", emp_name: empName ?? "", imageArray: captureImage)
        }else if (isPhotoForTech == false) && (isPhotoForAdmin == true) && (isPhotoForAttendence == false){
            handleCampareFaceAPICall(emp_image: captureImage)
        }else if (isPhotoForTech == false) && (isPhotoForAdmin == false) && (isPhotoForAttendence == true){
            handleCampareFaceAPICall(emp_image: captureImage)
        }else{
            let alert = Constants.shared.makeAlert(message: "Cannot Take Images As No Purpose Assigned", title: "Screen Error")
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func resetCamera(){
        captureSession?.stopRunning()
        captureOutput = nil
        capturedPhotos.removeAll()
    }
    
    func startCapturing() {
        guard let captureOutput = captureOutput else {
            print("Camera is not set up properly.")
            DispatchQueue.main.async {
                let alert = Constants.shared.makeAlert(message: "Camera Not Setup Properly", title: "Camera Error")
                self.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                        self.resetCamera()
                        alert.dismiss(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            return
        }
        
        let settings = AVCapturePhotoSettings()
        captureOutput.capturePhoto(with: settings, delegate: self)
    }
}
