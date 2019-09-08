//
//  NetworkManager.swift
//  ContactsApp
//
//  Created by deepali on 06/09/19 at 11:32 PM.
//  Copyright © 2019 meditab. All rights reserved.
//

import Foundation
import UIKit

struct API {
    static let baseURL = "http://gojek-contacts-app.herokuapp.com/contacts.json"
}

class NetworkManager {
    
    static let shared = NetworkManager(baseURL: API.baseURL)
    
    let baseURL : String
    
    var activityIndicator : UIActivityIndicatorView?
    
    typealias JSONDictionary = [String : Any]
    typealias JSONArray = [Any]
    
    typealias SuccessHandler = (_ data : Data) -> ()
    typealias ImageSuccessHandler = (_ image : UIImage) -> ()
    typealias ErrorHandler = (_ error : Error) -> ()
    
    lazy var defaultSession:URLSession = {
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type":"application/json; charset=UTF-8"]
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
    }()
    
    private init(baseURL:String){
        self.baseURL = baseURL
    }
    
    func getRequest(urlString:String,
                    view:UIView,
                    success: @escaping (SuccessHandler),
                    failure: @escaping (ErrorHandler)) {
        
        showProgressView(in: view)
        
        let url = urlString
        
        print(url)
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = defaultSession.dataTask(with: urlRequest, completionHandler: { (data,response,error) -> () in
            
            self.hideProgressView()
            
            guard error == nil else {
                failure(error!)
                return
            }
            
            if let aData = data, let urlResponse = response as? HTTPURLResponse, (200..<300).contains(urlResponse.statusCode) {
                print(aData)
                success(aData)
            }
        })
        task.resume()
        
}
    
    
    func postPutRequest(method: String, urlString: String, view: UIView, parameters: ContactsModel, success: @escaping (SuccessHandler), failure: @escaping (ErrorHandler)) {
        
        showProgressView(in: view)
        
        let url = String(format: urlString)
        guard let serviceUrl = URL(string: url) else { return }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = method
        
        do {
            let jsonData = try encoder.encode(parameters)
            request.httpBody = jsonData
            
        } catch {
            print(error.localizedDescription)
             failure(error)
        }
        
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
      
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            self.hideProgressView()
            
            guard error == nil else {
                failure(error!)
                return
            }
            
            if let aData = data, let urlResponse = response as? HTTPURLResponse, (200..<300).contains(urlResponse.statusCode) {
                print(aData)
                success(aData)
            }
        }.resume()
    }
    
    
    func showProgressView(in view:UIView) {
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator?.frame = view.bounds
        if let progressBar = activityIndicator{
            view.addSubview(progressBar)
        }
        activityIndicator?.startAnimating()
    }
    
    func hideProgressView() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.removeFromSuperview()
        }
    }

}
