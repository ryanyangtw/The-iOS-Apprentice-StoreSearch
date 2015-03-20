//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/16.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

  
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  
  var downloadTask: NSURLSessionDownloadTask?
  
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
      // Initialization code
    
    let selectedView = UIView(frame: CGRect.zeroRect)
    selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
    selectedBackgroundView = selectedView
    
  }

  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
  
  
  func kindForDisplay(kind: String) -> String {
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
  
  func configureForSearchResult(searchResult: SearchResult) {
    nameLabel.text = searchResult.name
    
    //println("In configureForSearchResult")
    if searchResult.artistName.isEmpty {
      self.artistNameLabel.text = "Unknow"
    } else {
      
      self.artistNameLabel.text = String(format: "%@ (%@)",
        searchResult.artistName, kindForDisplay(searchResult.kind))
    
    }
    
    // Tells the UIImageView to load the image from artworkUrl60. And to place it in the cell's image view
    self.artworkImageView.image = UIImage(named: "Placehokder")
    if let url = NSURL(string: searchResult.artworkUrl60) {
      self.downloadTask = artworkImageView.loadImageWithURL(url)
    }
    
  }
  
  // Cancel any image download that is still in progress
  override func prepareForReuse() {
    
    //println("In prepareForResue")
    super.prepareForReuse()
    self.downloadTask?.cancel()
    self.downloadTask = nil
    
    self.nameLabel.text = nil
    self.artistNameLabel.text = nil
    self.artworkImageView.image = nil
    
  }

}
