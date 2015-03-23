//
//  Search.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/23.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {

//  var searchResults = [SearchResult]()
//  var hasSearched = false
//  var isLoading = false
  
  enum State {
    case NotSearchedYet
    case Loading
    case NoResults
    case Results([SearchResult])
  }
  
  private(set) var state: State = .NotSearchedYet
  
  var dataTask: NSURLSessionDataTask?
  
  private var dataTadk: NSURLSessionDataTask? = nil
  
  
  // This create a new enumeration type named Category with four possible items
  enum Category: Int {
    case All = 0
    case Music = 1
    case Software = 2
    case EBook = 3
    
    // swift enums cannot have instance variables, only computed properties
    var entityName: String {
      switch self {
        case .All: return ""
        case .Music: return "musicTrack"
        case .Software: return "software"
        case .EBook: return "ebook"
      }
    }
  }
  
  
  init() {
  }
  
  func performSearchForText(text: String, category: Category, completion: SearchComplete) {
    
    if !text.isEmpty {
      

      self.dataTask?.cancel()
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      
      state = .Loading
    
      //self.isLoading = true
      // Here is the networking code
      //self.hasSearched = true
      //self.searchResults = [SearchResult]()
      
      
      // 1 Create the NSURL object with the search text
      let url = urlWithSearchText(text, category: category)
      
      // 2 grabs the "shared" session, which always exists and use a default configuration with respect to caching, cookies, and other web stuff
      let session = NSURLSession.sharedSession()
      
      // 3 data task are for sendeing HTTP GET requests to the server
      self.dataTask = session.dataTaskWithURL(url, completionHandler: {
        data, response, error in

        self.state = .NotSearchedYet
        var success = false
        
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
              
              var searchResults = self.parseDictionary(dictionary)
              if searchResults.isEmpty {
                self.state = .NoResults
              } else {
                searchResults.sort{ $0 < $1 }
                self.state = .Results(searchResults)
              }
              
            
              
              
              /*
              dispatch_async(dispatch_get_main_queue()) {
                self.isLoading = false
                self.tableView.reloadData()
              }
              */
              //println("Success! ")
              //self.isLoading = false
              success = true
              //return
            }
          }  //else {
            //println("Failure! \(response)")
          //}
        }
        
        
        dispatch_async(dispatch_get_main_queue()) {
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          completion(success)
        }
        
        
        // if code execuate to this line, if represent that the download was faild
        /*
        dispatch_async(dispatch_get_main_queue()) {
          self.hasSearched = false
          self.isLoading = false
          self.tableView.reloadData()
          self.showNetworkError()
        }
        */
        /*
        println("Faulure! \(response)")
        self.hasSearched = false
        self.isLoading = false
        */
        
      })
      
      // 5 start the task
      self.dataTask?.resume()
      
    }
    

    
    println("Searching...")
  }
  
  
  
  //MARK: Networking
  private func urlWithSearchText(searchText: String, category: Category) -> NSURL {
    

    let entityName = category.entityName
    
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
  
  private func parseJSON(data: NSData) -> [String: AnyObject]? {
    
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
  
  
  private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
    
    
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
  private func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
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
  
  
  private func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
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
  private func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
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
  
  private func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
    
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

}