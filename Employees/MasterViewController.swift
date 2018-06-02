//
//  MasterViewController.swift
//  Employees
//
//  Created by Lucyna Galik on 19/02/2018.
//  Copyright © 2018 Lucyna Galik. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, URLSessionDelegate {

    var detailViewController: DetailViewController? = nil
    var activityView: UIActivityIndicatorView?
    
    var session: URLSession?
    var jsonURL = URL(string: "http://developers.mub.lu/resources/team.json")
    var storeURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    var plistURL: String {
        return storeURL + "/allEmployees.plist"
    }
    
    var allEmployees = [Team]()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        innitSpinner()
        
        //load data
        if FileManager.default.fileExists(atPath: plistURL) {
            if allEmployees.count == 0 {
                var plistData: NSArray
                plistData = NSArray(contentsOfFile: plistURL)!
                allEmployees = readData(plistData as! [NSDictionary])
            }
        } else {
            let sessionConfig = URLSessionConfiguration.default
            session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            fetchJsonFeed(fromURL: jsonURL!)
        }

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    func innitSpinner() {
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        let center = view.center
        activityView?.center = center
        view.addSubview(activityView!)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let employee = allEmployees[indexPath.section].members[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = employee
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allEmployees.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEmployees[section].members.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allEmployees[section].teamName
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //higlight Team Lead
        if let _ = allEmployees[indexPath.section].members[indexPath.row].teamLead {
            cell.textLabel!.textColor = UIColor(named: "lightBlue")
        } else {
            cell.textLabel!.textColor = UIColor.black
        }
        
        cell.textLabel!.text = "\(allEmployees[indexPath.section].members[indexPath.row].firstName) \(allEmployees[indexPath.section].members[indexPath.row].lastName)"
        cell.detailTextLabel!.text = "\(allEmployees[indexPath.section].members[indexPath.row].role)"
        
        return cell
    }
    
    
    // MARK: - JSON and plist
    func fetchJsonFeed(fromURL myURL: URL) {
        self.activityView!.startAnimating()
        allEmployees = [Team]()
        
        let task = session!.dataTask(with: myURL) {
            (data, response, error) -> Void in
            
            do {
                let jsonFeed = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [NSDictionary]
                let plistData = jsonFeed as NSArray
                plistData.write(toFile: self.plistURL, atomically: true)
                self.allEmployees = self.readData(jsonFeed)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityView!.stopAnimating()
                }
        
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
        
        
    func readData(_ passedData: [NSDictionary]) -> [Team] {
        var result = [Team]()
        
        for object in passedData {
            if let members = object["members"] as? [[String:Any]] {
                var teamMembers = [Employee]()
                for member in members {
                    let employee = Employee(fromDictionary: member, withStoreURL: storeURL)
                    teamMembers.append(employee)
                }
                let teamName = object["teamName"] as! String
                result.append(Team(teamName: teamName, members: teamMembers))
            } else {
                let employee = Employee(fromDictionary: object as! [String : Any], withStoreURL: storeURL)
                result.append(Team(teamName: "", members: [employee]))
            }
        }
        
        return result
    }

}





