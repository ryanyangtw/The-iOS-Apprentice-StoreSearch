//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/16.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import Foundation

// Actually, you can put this func everywhere globally
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.name.localizedStandardCompare(rhs.name) == NSComparisonResult.OrderedAscending
}


class SearchResult {
  var name = ""
  var artistName = ""
  var artworkUrl60 = ""
  var artworkUrl100 = ""
  var storeUrl = ""
  var kind = ""
  var currency = ""
  var price = 0.0
  var genre = ""
  
  
  
  func kindForDisplay() -> String {
    switch kind {
    case "album": return "Albun"
    case "audiobook": return "Audio Book"
    case "book": return "Book"
    case "ebook": return "E-Book"
    case "feature-movie": return "Movie"
    case "music-video": return "Music Video"
    case "podcaast": return "Podcast"
    case "software": return "App"
    case "song": return "Song"
    case "tv-episode": return "TV Episode"
    default: return kind
    }
  }
  
  
}
