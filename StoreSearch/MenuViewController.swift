//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/25.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: class {
  func menuViewControllerSendSupportEmail(MenuViewController)
}

class MenuViewController: UITableViewController {
  
  weak var delegate: MenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if indexPath.row == 0 {
      delegate?.menuViewControllerSendSupportEmail(self)
    }
  }


}
