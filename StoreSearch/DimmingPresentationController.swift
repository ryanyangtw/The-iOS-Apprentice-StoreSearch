//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/20.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  
  
  lazy var dimmingView = GradientView(frame: CGRect.zeroRect)
  
  // presentationTransitionWillBegin is invoded when the new view controller is about to be shown on the screen
  override func presentationTransitionWillBegin() {
    
    // containerView: the view in the presentation occurs
    // containerView: is a new view that is placed on top of the SearchViewController, and it contains the views from the DetailViewController
    dimmingView.frame = containerView.bounds
    containerView.insertSubview(dimmingView, atIndex: 0)
    
    /*
    println("containerView: \(containerView)")
    println("containerView.subviews: \(containerView.subviews)")
    println("\(containerView.subviews.count)")
    */
  }
  
  /*
  override func presentationTransitionDidEnd(completed: Bool) {

    println("presentationTransitionWillBegin")
    println("containerView: \(containerView)")
    println("containerView.subviews: \(containerView.subviews)")
    println("\(containerView.subviews.count)")
  }
  */

  override func shouldRemovePresentersView() -> Bool {
    
    return false
  }
  
}



