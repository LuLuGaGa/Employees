//
//  Employee.swift
//  Employees
//
//  Created by Lucyna Galik on 19/02/2018.
//  Copyright © 2018 Lucyna Galik. All rights reserved.
//

import Foundation
import UIKit

struct Employee {
    let id: String
    let firstName: String
    let lastName: String
    let role: String
    let profileImageURL: String
    let teamLead : Bool?
    
    init(fromDictionary dictionary: [String: Any], withStoreURL storeURL: String) {
        self.firstName = dictionary["firstName"] as! String
        self.id = dictionary["id"] as! String
        self.lastName = dictionary["lastName"] as! String
        self.role = dictionary["role"] as! String
        self.teamLead = dictionary["teamLead"] as? Bool
        
        //image dowload, save, update URL
        let originalProfileImageURL = dictionary["profileImageURL"] as! String
        let url = URL(string: originalProfileImageURL)
        let data = try? Data(contentsOf: url!)
        let imageData = NSData(data: UIImagePNGRepresentation(UIImage(data: data!)!)!)
        self.profileImageURL = storeURL + "/" + id + ".png"
        _ = imageData.write(toFile: self.profileImageURL, atomically: true)
        
    }
}


