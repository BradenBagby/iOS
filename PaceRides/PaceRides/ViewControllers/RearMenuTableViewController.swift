//
//  RearMenuTableViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit


class MenuOption {
    
    var text: String
    var image: UIImage?
    
    init(text: String) {
        self.text = text
        self.image = nil
    }
    
    init(text: String, image: UIImage) {
        self.text = text
        self.image = image
    }
}


class RearMenuTableViewController: UIViewController {

    let menuOptions: [MenuOption] = [
        MenuOption(text: "Public"),
        MenuOption(text: "School"),
        MenuOption(text: "Settings"),
        MenuOption(text: "Report a Problem")
    ]
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerLabel.text = APPLICATION_TITLE
        
        self.paceUserUniversityDataDidChanged()
        UserModel.notificationCenter.addObserver(
            forName: .PaceUserUniversityDataDidChanged,
            object: nil,
            queue: OperationQueue.main,
            using: self.paceUserUniversityDataDidChanged
        )
    }
    
    
    func paceUserUniversityDataDidChanged(_: Notification? = nil) {
        if let pU = UserModel.sharedInstance(), let userSchoolProfile = pU.schoolProfile() {
            userSchoolProfile.getUniversityModel() { university, error in
                
                guard error == nil else {
                    return
                }
                
                guard let university = university else {
                    return
                }
                
                if let primaryColor = university.primaryColor,
                    let textColor = university.textColor {
                    
                    self.view.backgroundColor = primaryColor
                    self.tableView.backgroundColor = primaryColor
                    self.headerLabel.textColor = textColor
                    
                }
                
                if let universityShorthand = university.shorthand {
                    self.menuOptions[1].text = universityShorthand
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension RearMenuTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
        
        if let label = cell.textLabel {
            label.text = self.menuOptions[indexPath.item].text
        }
        
        return cell
    }
    
}

extension RearMenuTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "showPublic", sender: self)
            } else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "showSchool", sender: self)
            }
        }
        
    }
}
