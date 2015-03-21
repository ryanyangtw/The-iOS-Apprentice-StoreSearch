//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/21.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    
    return 0.3
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
    
      let durtion = transitionDuration(transitionContext)
      let containerView = transitionContext.containerView()
      
      
      
      UIView.animateWithDuration(durtion, animations: {
        
        //println("fromView.center.y : \(fromView.center.y)")
        //println("containerView.bounds.size.height : \(containerView.bounds.size.height)")
        //fromView.center.y = containerView.bounds.size.height - fromView.center.y
        fromView.center.y -= containerView.bounds.size.height
        fromView.transform = CGAffineTransformMakeScale(0.5, 0.5)
      
        }, completion: { finished in
          transitionContext.completeTransition(finished)})
      
    }
  }



}
