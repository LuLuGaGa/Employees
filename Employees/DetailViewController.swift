//
//  DetailViewController.swift
//  Employees
//
//  Created by Lucyna Galik on 19/02/2018.
//  Copyright © 2018 Lucyna Galik. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var role: UILabel!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = name {
                label.text = "\(detail.firstName) \(detail.lastName)"
            }
            if let label = role {
                label.text = detail.role
            }
            if let image = profileImage {
                image.image = UIImage(contentsOfFile: detail.profileImageURL)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    var detailItem: Employee? {
        didSet {
            configureView()
        }
    }


}

