//
//  ViewController.swift
//  ContactsApp
//
//  Created by deepali on 05/09/19 at 10:21 PM.
//  Copyright © 2019 meditab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    
    // MARK: Properties
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        initialize()
    }
    
    /// This method is used to have ui related changes.
    private func setupView() {
        
        
        
    }
    
    /// This method is used to initialize object.
    private func initialize() {
        getContacts(success: { (contacts) in
            print(contacts.count)
        }) { (errorMessage) in
            print(errorMessage)
        }
    }

    func getContacts(success: @escaping ([ContactsModel])->(), failure: @escaping (String)->()) {
        
        let url = "http://gojek-contacts-app.herokuapp.com/contacts.json"
        
        NetworkManager.shared.getRequest(urlString: url, view: view, success: { (data) in
            do {
                let meetings = try JSONDecoder().decode([ContactsModel].self, from: data)
                success(meetings)
            } catch {
                failure(error.localizedDescription)
            }
        }) { (error) in
            failure(error.localizedDescription)
        }
    }

}

