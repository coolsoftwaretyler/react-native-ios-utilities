//
//  RNIContentViewParentDelegate.swift
//  react-native-ios-utilities
//
//  Created by Dominic Go on 4/30/24.
//

import UIKit

@objc
public protocol RNIContentViewParentDelegate where Self: UIView  {

  var cachedLayoutMetrics: RNILayoutMetrics { get };
  
  func setSize(_ size: CGSize);
  
  func setPadding(_ insets: UIEdgeInsets);
  
  func setPositionType(_ positionType: RNILayoutMetrics.RNIPositionType);
};