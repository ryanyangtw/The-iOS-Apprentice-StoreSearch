//
//  ViewController.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/16.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  
  
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
  }

  @IBOutlet weak var searchBar: UISearchBar!
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  // Extract all about search into Search class
//  var searchResults = [SearchResult]()
//  
//  var hasSearched = false
//  var isLoading = false
//  
//  var dataTask: NSURLSessionDataTask?
  let search = Search()
  
  var landscapeViewController: LandscapeViewController?
  
  deinit {
    println("SearchViewController deinit")
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Tell the table view to add 64-point margin at the top. mande up 20 points for the status bar and 44 points for the Search Bar
    self.tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
    
    
    
    // Tell the app to use out custom cell nib
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    self.tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    self.tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
    self.tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    
    
    
    
    self.tableView.rowHeight = 80
    
    self.searchBar.becomeFirstResponder()
    
    
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  // This mehod is invoked when the device is rotated and any time the trait collection changes
  override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    
    super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    
    switch newCollection.verticalSizeClass {
    case .Compact:
      showLandscapeViewWithCoordinator(coordinator)
    case .Regular, .Unspecified:
      hideLandscapeViewWithCoordinator(coordinator)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  
  // presents an alert controller with an error message
  func showNetworkError() {
    let alert = UIAlertController(
      title: NSLocalizedString("WHoops....", comment: "Error alert: title"),
      message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"),
      preferredStyle: .Alert)
    
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
//MARK: Prepare for segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowDetail" {
      
      switch search.state {
      case .Results(let list):
        let detailViewController = segue.destinationViewController as DetailViewController
        let indexPath = sender as NSIndexPath
        let searchResult = list[indexPath.row]
        detailViewController.searchResult = searchResult
      default:
        break
      }
    
    }
  }
  
//MARK: Landscape
  func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
  
    // 1 Test for the the assumptions
    precondition(landscapeViewController == nil)
    
    // 2 Find the scene with ID "LandscapeViewController" in storyboard and instantiate it
    landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
    if let controller = landscapeViewController {
      
      controller.search = search
      
      // 3 This makes the landscape view just as big as the SearchViewController, covering the entire screen
      controller.view.frame = view.bounds
      controller.view.alpha = 0
      
      // 4 add the landscapr controller's view as a subview. This places it on top of the table view
      // using addChildViewController() to tell the SearchViewController that the LandscapeViewController is now managing that part of the screen
      view.addSubview(controller.view)
      addChildViewController(controller)
      
      coordinator.animateAlongsideTransition({ _ in
        controller.view.alpha = 1
        self.searchBar.resignFirstResponder()
        

        if self.presentedViewController != nil {
          self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        
        },
        completion: { _ in
          // Tell the new view controller that it now has a parent view controller
          controller.didMoveToParentViewController(self)
      })
      
    }
    
  }
  
  func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
    
    if let controller = landscapeViewController {
      
      // tell the view contoller that it is leaving the view controller hierarchy
      controller.willMoveToParentViewController(nil)
      
      coordinator.animateAlongsideTransition({ _ in
        controller.view.alpha = 0
        
        if self.presentedViewController != nil {
          self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        }, completion: { _ in
          // remove its view from the screen
          controller.view.removeFromSuperview()
          // dispose of the view controller
          controller.removeFromParentViewController()
          self.landscapeViewController = nil
      })
      

    }

  }


  
//MARK: IBAction
  @IBAction func segmentChanged(sender: UISegmentedControl) {
    performSearch()
  }
  
}


// MARK: searchViewController Delegate
extension SearchViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
      performSearch()
  }
  
  // It will be invoded when the user taps the Search button on the keyboard
  func performSearch() {
    
    if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
      
      search.performSearchForText(searchBar.text, category: category, completion: { success in
        
        if !success {
          self.showNetworkError()
        }
        
        self.tableView.reloadData()
        
        if let controller = self.landscapeViewController {
          controller.searchResultsReceived()
        }
        
        
      })
      
      tableView.reloadData()
      searchBar.resignFirstResponder()
    }
    

    /*
    if !searchBar.text.isEmpty {

      // It tells the UISearchBar taht it should no longer listen to keyboard input.
      searchBar.resignFirstResponder()
      self.dataTask?.cancel()
      
      self.isLoading = true
      self.tableView.reloadData()
      
      // Here is the networking code
      self.hasSearched = true
      self.searchResults = [SearchResult]()
      
      
      // 1 Create the NSURL object with the search text
      let url = self.urlWithSearchText(searchBar.text, category: segmentedControl.selectedSegmentIndex)
      
      // 2 grabs the "shared" session, which always exists and use a default configuration with respect to caching, cookies, and other web stuff
      let session = NSURLSession.sharedSession()

      // 3 data task are for sendeing HTTP GET requests to the server
      self.dataTask = session.dataTaskWithURL(url, completionHandler: {
        data, response, error in
        
        //println("On the main thread? " + (NSThread.currentThread().isMainThread ? "Yes" : "No"))
        // 4
        if let error = error {
          println("Failure! \(error)")
          
          // Ignore the error which was triggered by cancelling the task
          if error.code == -999 { return }
          
        } else if let httpResponse = response as? NSHTTPURLResponse {
          if httpResponse.statusCode == 200 {
            //println("Success! \(data)")
            if let dictionary = self.parseJSON(data) {
              self.searchResults = self.parseDictionary(dictionary)
              self.searchResults.sort{ $0 < $1 }
              
              dispatch_async(dispatch_get_main_queue()) {
                self.isLoading = false
                self.tableView.reloadData()
              }
              
              return
            }
          }  else {
            println("Failure! \(response)")
          }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
          self.hasSearched = false
          self.isLoading = false
          self.tableView.reloadData()
          self.showNetworkError()
        }
      
      })
      
      // 5 start the task
      self.dataTask?.resume()
      
      /*
      // 1 Gets a reference to the queue
      let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
      
      // 2 Dispatch a closure on it
      dispatch_async(queue) {
        let url = self.urlWithSearchText(searchBar.text)
        
        if let jsonString = self.performStoreRequestWithURL(url) {
          if let dictionary = self.parseJSON(jsonString) {
            self.searchResults = self.parseDictionary(dictionary)
            self.searchResults.sort{ $0 < $1 }
            
            // 3 
            // dispatch_get_main_queue: returns a reference to the main queue.
            // dispatch_async(): schedules a new closure on that queue.
            dispatch_async(dispatch_get_main_queue()) {
              self.isLoading = false
              self.tableView.reloadData()
            }
            return
          }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
          self.showNetworkError()
        }
      }
      */
      /*
      let url = urlWithSearchText(searchBar.text)
      println("URL: '\(url)'")
      
      if let jsonString = performStoreRequestWithURL(url) {
        //println("Received JSON string '\(jsonString)'")
        
        if let dictionary = parseJSON(jsonString) {
          println("Dictionary \(dictionary)")
          
          
          self.searchResults = parseDictionary(dictionary)
          
          /*
          searchResults.sort({ result1, result2 in
            return result1.name.localizedStandardCompare(result2.name) == NSComparisonResult.OrderedAscending
          })
          
          searchResuls.sort {$0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending}
          
          searchResuls.sort(<)
          */
          
          self.searchResults.sort{ $0 < $1 }
        
          self.isLoading = false
          
          // reload the table view to make the new rows visible
          // It will trigger the data source methods to read from array as well
          self.tableView.reloadData()
          return
        }
      }
      

      showNetworkError()
      */
    }
    */
  }
  
  
  // Make the status bar area was unified with the search bar
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
      return .TopAttached
  }

  
}


// MARK: TableView Datasource
extension SearchViewController: UITableViewDataSource {
  

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    
    switch search.state {
    case .NotSearchedYet:
      return 0
    case .Loading:
      return 1
    case .NoResults:
      return 1
    case .Results(let list):
      return list.count
    }
    
    /*
    if search.isLoading {
      return 1
    } else if !search.hasSearched {
      return 0
    } else if search.searchResults.count == 0 {
      return 1
    } else {
      return search.searchResults.count
    }
    */
    

  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    

    
    /*
    let cellIdentifier = "SearchResultCell"
    var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
    
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
    }
    */
    
    switch search.state {
    case .NotSearchedYet:
      println("NotSearchedYet")
      fatalError("Should never get here")

    case .Loading:
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as UITableViewCell
      
      let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
      spinner.startAnimating()
      
      return cell
      
    case .NoResults:
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
    case .Results(let list):
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
      
      let searchResult = list[indexPath.row]
      cell.configureForSearchResult(searchResult)
      return cell
    }
    
    /*
    if search.isLoading {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as UITableViewCell
      
      let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
      spinner.startAnimating()
      
      return cell
      
    } else if search.searchResults.count == 0 {
      
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
      
    } else {
      
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
      
      let searchResult = search.searchResults[indexPath.row]
      cell.configureForSearchResult(searchResult)
      
      /*
      cell.nameLabel.text = searchResult.name
      
      if searchResult.artistName.isEmpty {
        cell.artistNameLabel.text = "Unknow"
      } else {
        cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
      }
      */

      //cell.textLabel!.text = searchResult.name
      //cell.detailTextLabel!.text = searchResult.artistName
      return cell
    }
    */
  }

}



// MARK: TableView Delegate
extension SearchViewController: UITableViewDelegate {
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    // deselect the row with animation
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    // Manually Trigger Segue
    performSegueWithIdentifier("ShowDetail", sender: indexPath)
  }
  
  
  // Make sure that you can only select rows with actual search results (For "nothing found" row)
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    
    switch search.state {
    case .NotSearchedYet, .Loading, .NoResults:
      return nil
    case .Results:
      return indexPath
    }
    
    /*
    if search.searchResults.count == 0 || search.isLoading {
      return nil
    } else {
      return indexPath
    }
    */
  }
  
  
}









