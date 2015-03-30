//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/20.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {
  
  @IBOutlet weak var popupView: UIView!
  
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var priceButton: UIButton!
  
  var searchResult: SearchResult! {
    // property observer
    didSet {
      if isViewLoaded() {
        updateUI()
      }
    }
  }
  
  var downloadTask: NSURLSessionDownloadTask?
  
  var isPopUp = false
  
  enum AnimationStyle {
    case Slide
    case Fade
  }
  
  var dismissAnimationStyle = AnimationStyle.Fade
  
  
  deinit {
    //println("deinit \(self)")
    println("DetailViewController  deinit")
    self.downloadTask?.cancel()
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    
    // Ask the pop-up view for its layer and then set the corner radius of that layer to 10 points
    popupView.layer.cornerRadius = 10
    
//    let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
//    gestureRecognizer.cancelsTouchesInView = false
//    gestureRecognizer.delegate = self
//    view.addGestureRecognizer(gestureRecognizer)
    
    if self.searchResult != nil {
      updateUI()
    }
    
    
    //view.backgroundColor = UIColor.clearColor()
    
    //self.priceButton.setTitle("TEST", forState: .Normal)
    
    
    if isPopUp {
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
      gestureRecognizer.cancelsTouchesInView = false
      gestureRecognizer.delegate = self
      view.addGestureRecognizer(gestureRecognizer)
      
      view.backgroundColor = UIColor.clearColor()

    } else {
      view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
      popupView.hidden = true
      
      if let displayName = NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? NSString {
        title = displayName
      }
    }
    
    

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
      self.artistNameLabel.text = NSLocalizedString("Unknown", comment: "Localized artistNameLabel in DetailViewController: Unknown")
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
      priceText = NSLocalizedString("Free", comment: "Localized price: Free")
      
    } else if let text = formatter.stringFromNumber(searchResult.price) {
      priceText = text
    } else {
      priceText = ""
    }

    priceButton.setTitle(priceText, forState: .Normal)
    
    
    
    if let url = NSURL(string: searchResult.artworkUrl100) {
      self.downloadTask = artworkImageView.loadImageWithURL(url)
    }
    
    // Exercise p.273
    // Smooth entry of the detail view when its added to the screen.
    //popupView.hidden = false
    if (!isPopUp) && (popupView.hidden == true) {
      popupView.alpha = 0.0
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        
        self.popupView.hidden = false;
        self.popupView.alpha = 1.0;
        
        }, completion: nil)
    }
    
  }
  
//MARK: Prepare for segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowMenu" {
      let controller = segue.destinationViewController as MenuViewController
      controller.delegate = self
    }
  }
 
// MARK: IBAction
  @IBAction func close() {
    // This mehod will dealloc the detailViewController
    dismissAnimationStyle = .Slide
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

    switch dismissAnimationStyle {
    case .Slide:
      return SlideOutAnimationController()
    case .Fade:
      return FadeOutAnimationController()
    }
    
  }
  
}

// MARK: UIGestureRecoginzerDelegate
extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    
    return (touch.view === view)
  
  }
  
}


//MARK: MenuViewControllerDelegate
extension DetailViewController: MenuViewControllerDelegate {
  func menuViewControllerSendSupportEmail(MenuViewController) {
    
    // hide the popover
    dismissViewControllerAnimated(true) {
      if MFMailComposeViewController.canSendMail() {
        let controller = MFMailComposeViewController()
        controller.setSubject(NSLocalizedString("Support Request", comment: "Email subject"))
        controller.setToRecipients(["hiphubryan@gmail.com"])
          self.presentViewController(controller, animated: true, completion: nil)
        
        controller.mailComposeDelegate = self
        
        // Default is page sheet
        controller.modalPresentationStyle = .FormSheet
      
      }
    }
    
  }
}

//MARK: MFMailComposeViewControllerDelegate
extension DetailViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
    
    if let error = error {
      println("Send email error: \(error)")
    }
    dismissViewControllerAnimated(true, completion: nil)
    
  }


}

