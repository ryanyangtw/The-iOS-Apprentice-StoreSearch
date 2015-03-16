//
//  ViewController.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/16.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  
  @IBOutlet weak var tableView: UITableView!
  
  var searchResults = [SearchResult]()
  
  var hasSearched = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Tell the table view to add 64-point margin at the top. mande up 20 points for the status bar and 44 points for the Search Bar
    self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


// MARK: searchViewController Delegate
extension SearchViewController: UISearchBarDelegate {

  
  // It will be invoded when the user taps the Search button on the keyboard
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
    // It tells the UISearchBar taht it should no longer listen to keyboard input.
    searchBar.resignFirstResponder()
    
    
    
    searchResults = [SearchResult]()
    
    if searchBar.text != "justin bieber" {
      for i in 0...2 {
        let searchResult = SearchResult()
        searchResult.name = String(format: "Fake Result %d for", i)
        searchResult.artistName = searchBar.text
        searchResults.append(searchResult)
        
        // searchResults.append( String(format: "Fake Result %d for '%@'", i , searchBar.text) )
      }
    }
    
    
    self.hasSearched = true
    
    // reload the table view to make the new rows visible
    // It will trigger the data source methods to read from array as well
    self.tableView.reloadData()
    
    //println("The search text is: '\(searchBar.text)'")
  }
  
  
  // Make the status bar area was unified with the search bar
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
      return .TopAttached
  }
  
}


// MARK: TableView Datasource
extension SearchViewController: UITableViewDataSource {
  

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
    

  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    
    let cellIdentifier = "SearchResultCell"
    
    var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
    
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
    }
    
    if searchResults.count == 0 {
      cell.textLabel!.text = "(Nothing found)"
      cell.detailTextLabel!.text = ""
    } else {
      
      let searchResult = searchResults[indexPath.row]
      cell.textLabel!.text = searchResult.name
      cell.detailTextLabel!.text = searchResult.artistName
    
    }

    
    return cell
  }

}



// MARK: TableView Delegate
extension SearchViewController: UITableViewDelegate {
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    // deselect the row with animation
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  
  // Make sure that you can only select rows with actual search results (For "nothing found" row)
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    
    if searchResults.count == 0 {
      return nil
    } else {
      return indexPath
    }
  
  }
  
  
}









