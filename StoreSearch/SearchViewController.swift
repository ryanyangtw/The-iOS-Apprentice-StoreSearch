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
  
  var searchResults = [SearchResult]()
  
  var hasSearched = false
  var isLoading = false
  
  var dataTask: NSURLSessionDataTask?
  
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

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

//MARK: Networking
  func urlWithSearchText(searchText: String, category: Int) -> NSURL {
    
    var entityName: String
    switch category {
      case 1: entityName = "musicTrack"
      case 2: entityName = "software"
      case 3: entityName = "ebook"
      default: entityName = ""
    }
    
    // Do the URL encoding
    let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    
    let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
    
    // Tuen this string into NSURL object
    let url = NSURL(string: urlString)
    return url!
    
  }
  
  /*
  func performStoreRequestWithURL(url: NSURL) -> String? {
  
    var error: NSError?
    
    // A constructor of the String class that returns a new string object with the data that if receives from the server at the other end of the URL
    if let resultString = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: &error) {
    
      return resultString
      
      // check if errror is nil or not
    } else if let error = error {
      println("Download Error: \(error)")
    } else {
      println("Unknown Download Error")
    }
    
    return nil
  
  }
  */
  
  func parseJSON(data: NSData) -> [String: AnyObject]? {
    
    // Convert string into an NSData object
    //if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
      
    // Convert NSData object into a Dictionary
    var error: NSError?
    if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
      return json
    } else if let error = error{
      println("JSON Error: \(error)")
    } else {
      println("Unknow JSON Error")
    }
    //}
    
    return nil
  }
  
  
  func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
    
    
    var searchResults = [SearchResult]()
    
    // 1 make sure the dictionary has a key named results that contains an array
    if let array: AnyObject = dictionary["results"] {
      // 2
      for resultDict in array as [AnyObject] {
        
        // 3 make sure these objects really do represnet a dictionary.
        if let resultDict = resultDict as? [String: AnyObject] {
          
          var searchResult: SearchResult?
          // 4
          if let wrapperType = resultDict["wrapperType"] as? NSString {
            
            switch wrapperType {
              case "track":
                searchResult = parseTrack(resultDict)
              case "audiobook":
                searchResult = parseAudioBook(resultDict)
              case "software":
                searchResult = parseSoftware(resultDict)
              default:
                break
            }
            
            /*
            if let kind = resultDict["kind"] as? NSString {
              println("wrapperType: \(wrapperType), kind: \(kind)")
            }
            */
          } else if let kind = resultDict["kind"] as? NSString {
            if kind == "ebook" {
              searchResult = parseEBook(resultDict)
            }
          }
          
          if let result = searchResult {
            searchResults.append(result)
          }
          
        // 5
        } else {
          println("Expected a dictionary")
        }
      }
    } else {
    
      println("Expected 'results' array")
    }
    
    return searchResults
  }
  
//MARK: Parse Different categories
  func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkUrl60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkUrl100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeUrl = dictionary["trackViewUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["trackPrice"] as? NSNumber {
      searchResult.price = Double(price)
    }
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    
    return searchResult
  }
  
  
  func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["collectionName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkUrl60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkUrl100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeUrl = dictionary["collectionViewUrl"] as NSString
    searchResult.kind = "audiobook"
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["collectionPrice"] as? NSNumber {
      searchResult.price = Double(price)
    }
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    
    return searchResult
  }
  
  // ??
  func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkUrl60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkUrl100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeUrl = dictionary["trackViewUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["price"] as? NSNumber {
      searchResult.price = Double(price)
    }
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    
    return searchResult
    
  }
  
  func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
    
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkUrl60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkUrl100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeUrl = dictionary["trackViewUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["price"] as? NSNumber {
      searchResult.price = Double(price)
    }
 
    if let genres: AnyObject = dictionary["genres"] {
      searchResult.genre = ", ".join(genres as [String])
    }
    
    return searchResult
  }
  
  
  
  // presents an alert controller with an error message
  func showNetworkError() {
    let alert = UIAlertController(
      title: "WHoops....",
      message: "There was an error reading from the iTunes Store. Please try again.",
      preferredStyle: .Alert)
    
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
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
    
  }
  
  
  // Make the status bar area was unified with the search bar
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
      return .TopAttached
  }
  
}


// MARK: TableView Datasource
extension SearchViewController: UITableViewDataSource {
  

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if isLoading {
      return 1
    } else if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
    

  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    

    
    /*
    let cellIdentifier = "SearchResultCell"
    var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
    
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
    }
    */
    if isLoading {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as UITableViewCell
      
      let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
      spinner.startAnimating()
      
      return cell
      
    } else if searchResults.count == 0 {
      
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
      
    } else {
      
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
      
      let searchResult = searchResults[indexPath.row]
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
    
    if searchResults.count == 0 || isLoading {
      return nil
    } else {
      return indexPath
    }
  
  }
  
  
}









