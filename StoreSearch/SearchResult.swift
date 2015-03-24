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
  
  
  private let displayNamesForKind = [
    "album": NSLocalizedString("Albun", comment: "Localized kind: Album"),
    "audiobook": NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book"),
    "book": NSLocalizedString("Book", comment: "Localized kind: Book"),
    "ebook": NSLocalizedString("E-Book", comment: "Localized kind: E-Book"),
    "feature-movie": NSLocalizedString("Movie", comment: "Localized kind: Feature Movie"),
    "music-video": NSLocalizedString("Music Video", comment: "Localized kind: Music Video"),
    "podcaast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
    "software": NSLocalizedString("App", comment: "Localized kind: Software"),
    "song": NSLocalizedString("Song", comment: "Localized kind: Song"),
    "tv-episode": NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
  ]
  
 
  func kindForDisplay() -> String {
    
    // nil coalescing operator
    return displayNamesForKind[self.kind] ?? self.kind
    
    // the code above is equal to below
    /*
    if let name = displayNamesForKind[kind] {
      return name
    } else {
      return kind
    }
    */
    
    
    /*
    switch kind {
    case "album":
      return NSLocalizedString("Albun", comment: "Localized kind: Album")
    case "audiobook":
      return NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book")
    case "book":
      return NSLocalizedString("Book", comment: "Localized kind: Book")
    case "ebook":
      return NSLocalizedString("E-Book", comment: "Localized kind: E-Book")
    case "feature-movie":
      return NSLocalizedString("Movie", comment: "Localized kind: Feature Movie")
    case "music-video":
      return NSLocalizedString("Music Video", comment: "Localized kind: Music Video")
    case "podcaast":
      return NSLocalizedString("Podcast", comment: "Localized kind: Podcast")
    case "software":
      return NSLocalizedString("App", comment: "Localized kind: Software")
    case "song":
      return NSLocalizedString("Song", comment: "Localized kind: Song")
    case "tv-episode":
      return NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
    default:
      return kind
    }
    */
  }

  
}
