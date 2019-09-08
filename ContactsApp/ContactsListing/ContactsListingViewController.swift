//
//  ContactsListingViewController.swift
//  ContactsApp
//
//  Created by deepali on 07/09/19 at 10:41 PM.
//  Copyright © 2019 meditab. All rights reserved.
//

import UIKit


class ContactsListingViewController: UITableViewController {

    // MARK: Outlets
    
    // MARK: Properties
    var contactDictionary = [String: [ContactsModel]]()
    var contactSectionTitles = [String]()
    var contacts: [ContactsModel]?
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        setupView()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false

    }
    
    /// This method is used to have ui related changes.
    private func setupView() {
        
    }
    
    /// This method is used to initialize object.
    private func initialize() {
        
        getContacts(success: { [weak self](contacts) in
            print(contacts.count)
            self?.contacts = contacts
            
            self?.createSectionTitles()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }) { (errorMessage) in
            print(errorMessage)
        }
    }
    
    func createSectionTitles() {
        for contact in contacts ?? [] {
            let contactKey = String(contact.firstName?.prefix(1).uppercased() ?? "")
            if var contactValues = contactDictionary[contactKey] {
                contactValues.append(contact)
                contactDictionary[contactKey] = contactValues
            } else {
                contactDictionary[contactKey] = [contact]
            }
        }
        
        contactSectionTitles = [String](contactDictionary.keys)
        contactSectionTitles = contactSectionTitles.sorted(by: { $0 < $1 })
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contactSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contactKey = contactSectionTitles[section]
        if let contactValues = contactDictionary[contactKey] {
            return contactValues.count
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsCell", for: indexPath) as? ContactsCell

        // Configure the cell...
        let contactKey = contactSectionTitles[indexPath.section]
        if let contactValues = contactDictionary[contactKey] {
            cell?.setDataForCell(data: contactValues[indexPath.row])
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactSectionTitles[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactSectionTitles
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController
        
        let contactKey = contactSectionTitles[indexPath.section]
        if let contactValues = contactDictionary[contactKey] {
            destination?.id = contactValues[indexPath.row].id
        }
        destination?.delegate = self
        self.navigationController?.pushViewController(destination!, animated: true)
    }
    
    // MARK: Action methods
    
    @IBAction func addContactButtonClicked(_ sender: Any) {
        
        let destination = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddUpdateViewController") as? AddUpdateViewController
        destination?.updateContactDelegate = self
        destination?.screenType = .add
        self.present(destination!, animated: true, completion: nil)
    }
    
}

extension ContactsListingViewController: UpdateContactsDelegate {
    
    func updateContacts() {
        contacts = []
        getContacts(success: { [weak self](contacts) in
            print(contacts.count)
            self?.contacts = contacts
            
            self?.createSectionTitles()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }) { (errorMessage) in
            print(errorMessage)
        }
    }
}
