//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/20.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet weak var popupView: UIView!
  
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var priceButton: UIButton!
  
  var searchResult: SearchResult!
  
  var downloadTask: NSURLSessionDownloadTask?
  
  
  deinit {
    //println("deinit \(self)")
    self.downloadTask?.cancel()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    
    // Ask the pop-up view for its layer and then set the corner radius of that layer to 10 points
    popupView.layer.cornerRadius = 10
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self
    view.addGestureRecognizer(gestureRecognizer)
    
    if self.searchResult != nil {
      updateUI()
    }
    
    
    view.backgroundColor = UIColor.clearColor()
    
    //self.priceButton.setTitle("TEST", forState: .Normal)

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  

  required init(coder aDecoder: NSCoder) {
    
    super.init(coder: aDecoder)
    
    // Tell the UIKit that this View Controller uses a custom presentation
    modalPresentationStyle = .Custom
    transitioningDelegate = self
  }
  
  func updateUI() {
    self.nameLabel.text = self.searchResult.name
    
    if self.searchResult.artistName.isEmpty {
      self.artistNameLabel.text = "Unknows"
    } else {
      self.artistNameLabel.text = self.searchResult.artistName
    }
    
    self.kindLabel.text = self.searchResult.kindForDisplay()
    self.genreLabel.text = searchResult.genre
    
    // NSNumberFormatter insert the proper symbol, such as $ or € or ¥, and formats the monetary amount according to the user’s regional settings.
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.currencyCode = searchResult.currency
    
    var priceText: String
    if searchResult.price == 0 {
      priceText = "Free"
    } else if let text = formatter.stringFromNumber(searchResult.price) {
      priceText = text
    } else {
      priceText = ""
    }

    priceButton.setTitle(priceText, forState: .Normal)
    
    
    
    if let url = NSURL(string: searchResult.artworkUrl100) {
      self.downloadTask = artworkImageView.loadImageWithURL(url)
    }
    
    
  }
 
// MARK: IBAction
  @IBAction func close() {
    // This mehod will dealloc the detailViewController
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func openInStore() {
    if let url = NSURL(string: self.searchResult.storeUrl) {
      UIApplication.sharedApplication().openURL(url)
    }
  }


}


//MARK: UIViewControllerTransitioningDelegate
extension DetailViewController: UIViewControllerTransitioningDelegate {
  
  // Tells the UIKit what object it should use to perform the transition to the Detail View Controller
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
    
    
    return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimatinoController()
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideOutAnimationController()
  }
  
}

// MARK: UIGestureRecoginzerDelegate
extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    
    return (touch.view === view)
  
  }
  
}


