//
//  AllChannelTableViewController.swift
//  Youtube
//
//  Created by MAC on 9/30/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit
import RealmSwift

protocol SelectedChannelDelegate {
    func changeChannel(channelId: String)
}

class AllChannelTableViewController: UITableViewController {
    var channelIdSelected: String = ""
    var selectedChannelDelegate: SelectedChannelDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        if let _channelId = realm.objects(Channel.self).first {
            channelIdSelected = _channelId.id
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allChannelId.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellTitleChannel", for: indexPath)
        cell.textLabel?.text = allTitleChannel[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 15)
        if let indexChannel = allChannelId.index(of: channelIdSelected) {
            if(indexPath.row == indexChannel) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        if let channel = realm.objects(Channel.self).first {
            try! realm.write {
                channel.id = allChannelId[indexPath.row]
            }
        }
        dismiss(animated: true) {
            self.selectedChannelDelegate?.changeChannel(channelId: allChannelId[indexPath.row])
        }
    }
   
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
