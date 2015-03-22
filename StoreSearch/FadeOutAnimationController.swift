//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by Ryan on 2015/3/22.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
  
    return 0.4
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
  
    if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
    
      let duration = transitionDuration(transitionContext)
      
      UIView.animateWithDuration(duration, animations: {
        fromView.alpha = 0
        }, completion: { finished in
          transitionContext.completeTransition(true)
      })
    }
  }



}
