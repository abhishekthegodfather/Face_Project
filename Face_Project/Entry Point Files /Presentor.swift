//
//  AdminPresentor.swift
//  Face_Project
//
//  Created by Cubastion on 05/06/23.
//

import Foundation
import UIKit

class Presenter {
    static let shared = Presenter()
    func getAndPostDataHandler(urlString: String, emp_code: String, presentingViewController: UIViewController?, completion: @escaping (Any?) -> Void) {
        NetworkHandler.shared.genericApiCaller(urlString: urlString, emp_code: emp_code, presentingViewController: presentingViewController) { result in
            if !result.isEmpty {
                do {
                    let decodedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
                    completion(decodedResult)
                } catch {
                    completion(nil)
                }
            } else {
                print("Cannot Connect to API")
                completion(nil)
            }
        }
    }
    
    
    func getAndPostManyImageHandler(urlString: String, emp_code: String, full_name: String, presentingViewController: UIViewController?, imageArray: [UIImage] ,completion: @escaping(Any?) -> Void){
        
        NetworkHandler.shared.genericImageArrayCaller(urlString: urlString, presentingViewController: presentingViewController, images: imageArray, empCode: emp_code, empName: full_name) { result in
            if !result.isEmpty {
                do{
                    let decodedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
                    completion(decodedResult)
                }catch{
                    completion(nil)
                }
            }else{
                print("Cannot Connect with API")
                completion(nil)
            }
        }
    }
    
    
    func getAndPostOneImageHandler(urlString: String, presentingViewController: UIViewController?, image: UIImage ,completion: @escaping(Any?) -> Void){
        
        NetworkHandler.shared.genericImageCaller(urlString: urlString, presentingViewController: presentingViewController, withImage: image) { result in
            
            if !result.isEmpty {
                do{
                    let decodedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
                    completion(decodedResult)
                }catch{
                    completion(nil)
                }
            }else{
                print("Cannot Connect with API")
                completion(nil)
            }
        }
    }
    
    
    func postMailAPICaller(urlString: String, empIssueTitle: String, empIssueDesc: String ,empEmailId: String, presentingViewController: UIViewController?, completion: @escaping (Any?) -> Void) {
        NetworkHandler.shared.sendMailApiCaller(urlString: urlString, emailId: empEmailId, issueDesc: empIssueDesc, issueTitle: empIssueTitle, presentingViewController: presentingViewController) { result in
            
            if !result.isEmpty {
                do{
                    let decodedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
                    completion(decodedResult)
                }catch{
                    completion(nil)
                }
            }else{
                print("Cannot Connect with API")
                completion(nil)
            }
        }
    }
}
