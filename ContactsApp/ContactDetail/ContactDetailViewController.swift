//
//  ContactDetailViewController.swift
//  ContactsApp
//
//  Created by deepali on 08/09/19 at 1:01 AM.
//  Copyright © 2019 meditab. All rights reserved.
//

import Foundation
import UIKit


protocol UpdateContactsDelegate {
    func updateContacts()
}


class ContactDetailViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var contactBackButton: UIButton!
    
    // MARK: Properties
    var id: Int?
    var contact: ContactsModel?
    var delegate: UpdateContactsDelegate?
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        initialize()
    }
    
    /// This method is used to have ui related changes.
    private func setupView() {
        
        setGradientBackground()
        contactBackButton.contentMode = .center
        contactBackButton.imageView?.contentMode = .scaleAspectFit
        
        self.navigationController?.isNavigationBarHidden = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
    }
    
    /// This method is used to initialize object.
    private func initialize() {
        
        getContactById(id: id ?? 0, success: { [weak self](contact) in
            self?.contact = contact
            DispatchQueue.main.async {
                self?.setDataOnScreen(contact: contact)
            }
            
        }) { (error) in
            print(error)
        }
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
    
    func setDataOnScreen(contact: ContactsModel) {
        
        nameLabel.text = "\(contact.firstName ?? "") \(contact.lastName ?? "")"
        numberLabel.text = (contact.phoneNumber != nil) ? "\(contact.phoneNumber ?? "")" : "-"
        emailLabel.text = (contact.email != nil) ? contact.email : "-"
        favoriteButton.isSelected = contact.favorite ?? false
        
        let url = URL(string: contact.profilePic ?? "")
        let data = try? Data(contentsOf: url ?? URL(fileURLWithPath: ""))
        
        if let imageData = data {
            let image = UIImage(data: imageData)
            profileImageView.image = image
        }
    }
    
    func getContactById(id: Int,success: @escaping (ContactsModel)->(), failure: @escaping (String)->()) {
        
        let url = "http://gojek-contacts-app.herokuapp.com/contacts/\(id).json"
        
        NetworkManager.shared.getRequest(urlString: url, view: view, success: { (data) in
            do {
                let meetings = try JSONDecoder().decode(ContactsModel.self, from: data)
                success(meetings)
            } catch {
                failure(error.localizedDescription)
            }
        }) { (error) in
            failure(error.localizedDescription)
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
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL as URL)
                    
                }
            }
        }
    }
    
    // MARK: Action Methods
    @IBAction func messageButtonClicked(_ sender: Any) {
    }
    
    @IBAction func callButtonClicked(_ sender: Any) {
        
        if (contact?.phoneNumber != nil) {
            callNumber(phoneNumber: contact?.phoneNumber ?? "")
        }
        
    }
    
    @IBAction func emailButtonClicked(_ sender: Any) {
    }
    
    @IBAction func favoriteButtonClicked(_ sender: Any) {
        
        contact?.favorite = !(contact?.favorite ?? false)
        
        updateContact(success: { (updatedContact) in
            
            DispatchQueue.main.async {
                self.favoriteButton.isSelected = (updatedContact.favorite ?? false)
            }
            
            self.delegate?.updateContacts()
            
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func contactBackButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        
        let destination = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddUpdateViewController") as? AddUpdateViewController
        destination?.contact = contact
        destination?.delegate = self
        destination?.screenType = .update
        self.present(destination!, animated: true, completion: nil)
    }
    
}

extension ContactDetailViewController: AddUpdateContactDelegate {
    
    func updateContact(contact: ContactsModel) {
        self.contact = contact
        
        DispatchQueue.main.async {
            self.setDataOnScreen(contact: contact)
        }
        delegate?.updateContacts()
    }
}
