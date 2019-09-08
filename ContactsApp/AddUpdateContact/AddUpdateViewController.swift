//
//  AddUpdateViewController.swift
//  ContactsApp
//
//  Created by deepali on 08/09/19 at 3:01 PM.
//  Copyright © 2019 meditab. All rights reserved.
//

import UIKit

enum AddUpdateScreenType {
    case add
    case update
}

protocol AddUpdateContactDelegate: class {
    
    func updateContact(contact: ContactsModel)
}

class AddUpdateViewController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastnameTextfield: UITextField!
    @IBOutlet weak var mobileTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    
    // MARK: Properties
    var contact: ContactsModel?
    var delegate: AddUpdateContactDelegate?
    var screenType: AddUpdateScreenType?
    var updateContactDelegate: UpdateContactsDelegate?
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        initialize()
    }
    
    /// This method is used to have ui related changes.
    private func setupView() {
        
        tableView.tableFooterView = UIView()
        
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        
        profileImageView.clipsToBounds = true
        setGradientBackground()
        setupScreen()
        
    }
    
    /// This method is used to initialize object.
    private func initialize() {
        
    }

    
    // sets gradient to the header view
    func setGradientBackground() {
        let colorTop =  #colorLiteral(red: 0.9881629348, green: 0.9882776141, blue: 0.9881102443, alpha: 1).cgColor
        let colorBottom = #colorLiteral(red: 0.8254702687, green: 0.9654600024, blue: 0.9367839098, alpha: 1).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.headerView.bounds
        gradientLayer.frame.size.width = UIScreen.main.bounds.width
        
        self.headerView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func setupScreen() {
        
        if (screenType == .update) {
            firstNameTextfield.text = contact?.firstName
            lastnameTextfield.text = contact?.lastName
            emailTextfield.text = (contact?.email != nil) ? contact?.email : ""
            mobileTextfield.text = (contact?.phoneNumber != nil) ? contact?.phoneNumber : ""
            
            let url = URL(string: contact?.profilePic ?? "")
            let data = try? Data(contentsOf: url ?? URL(fileURLWithPath: ""))
            
            if let imageData = data {
                let image = UIImage(data: imageData)
                profileImageView.image = image
            }
        }
    }
    
    func updateContact(success: @escaping (ContactsModel)->(), failure: @escaping (String)->()) {
        
        let url = "http://gojek-contacts-app.herokuapp.com/contacts/\(contact?.id ?? 0).json"
        
        NetworkManager.shared.postPutRequest(method: "PUT", urlString: url, view: view, parameters: contact!, success: { (contact) in
            do {
                let contact = try JSONDecoder().decode(ContactsModel.self, from: contact)
                success(contact)
            } catch {
                failure(error.localizedDescription)
            }

        }) { (error) in
            failure(error.localizedDescription)
        }
    }
    
    func addContact(success: @escaping (ContactsModel)->(), failure: @escaping (String)->()) {
        
        let url = "http://gojek-contacts-app.herokuapp.com/contacts.json"
        
        NetworkManager.shared.postPutRequest(method: "POST", urlString: url, view: view, parameters: contact!, success: { (contact) in
            do {
                let contact = try JSONDecoder().decode(ContactsModel.self, from: contact)
                success(contact)
            } catch {
                failure(error.localizedDescription)
            }
            
        }) { (error) in
            failure(error.localizedDescription)
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "First Name/Last Name fields cannot be empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    // MARK: Action methods
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        
        if (firstNameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false) || (lastnameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false) {
            showAlert()
            return
        }
        
        
        if (screenType == .add) {
            contact = ContactsModel()
        }
        contact?.firstName = firstNameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        contact?.lastName = lastnameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        contact?.phoneNumber = mobileTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        contact?.email = emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if (screenType == .update) {
            updateContact(success: { [weak self](contact) in
                self?.dismiss(animated: true, completion: {
                    self?.delegate?.updateContact(contact: contact)
                })
            }) { (error) in
                print(error)
            }
        }
        else {
            addContact(success: { [weak self](contact) in
                self?.dismiss(animated: true, completion: {
                    self?.updateContactDelegate?.updateContacts()
                })
            }) { (error) in
                print(error)
            }
        }
        
    }
}
