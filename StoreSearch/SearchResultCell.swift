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
  

  
  func configureForSearchResult(searchResult: SearchResult) {
    nameLabel.text = searchResult.name
    
    //println("In configureForSearchResult")
    if searchResult.artistName.isEmpty {
      self.artistNameLabel.text = NSLocalizedString("Unknown", comment: "Localized artistNameLabel in searchResultCell: Unknown")
    } else {
      
      //self.artistNameLabel.text = String(format: "%@ (%@)",
        //searchResult.artistName, searchResult.kindForDisplay())
      self.artistNameLabel.text = String(format: NSLocalizedString("ARTIST_NAME_LABEL_FORMAT", comment: "Format for artist name label"), searchResult.artistName, searchResult.kindForDisplay())
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
