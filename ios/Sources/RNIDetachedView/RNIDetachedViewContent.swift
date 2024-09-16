//
//  RNIDetachedViewContent.swift
//  react-native-ios-context-menu
//
//  Created by Dominic Go on 8/24/24.
//

import UIKit
import DGSwiftUtilities


@objc(RNIDetachedViewContent)
public final class RNIDetachedViewContent:
  UIView, RNIContentView, RNIContentViewInternal {

  // MARK: - Embedded Types
  // ----------------------
  
  public enum Events: String, CaseIterable, RNIViewInternalEvents {
    case onRawNativeEvent;
    case onContentViewDidDetach;
    case OnViewDidDetachFromParent;
  };
  
  // MARK: - Static Properties
  // -------------------------
  
  public static var propKeyPathMap: PropKeyPathMap = [
    "shouldImmediatelyDetach": \.shouldImmediatelyDetach,
  ];
  
  // MARK: - Properties - RNIContentViewDelegate
  // -------------------------------------------
  
  public weak var parentReactView: RNIContentViewParentDelegate?;
  
  // MARK: - Properties
  // ------------------
  
  public var didDetach = false;
  
  public var viewsToDetach: [RNIContentViewParentDelegate] = [];
  public var detachedViews: [RNIContentViewParentDelegate] = [];
  
  // MARK: - Properties - Props
  // --------------------------
  
  public var reactProps: NSDictionary = [:];
  
  public var shouldImmediatelyDetach = false {
    willSet {
      guard newValue,
            self.window != nil
      else { return };
      
      try? self.detach();
      try? self.detachSubviews();
    }
  };
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var hasViewsToDetach: Bool {
    self.viewsToDetach.count > 0;
  };
  
  public var hasDetachedViews: Bool {
    self.detachedViews.count > 0;
  };

  // MARK: Init
  // ----------
  
  public override init(frame: CGRect) {
    super.init(frame: frame);
  };
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented");
  };
  
  // MARK: - View Lifecycle
  // ----------------------
  
  public override func willMove(toWindow newWindow: UIWindow?) {
    if self.shouldImmediatelyDetach {
      try? self.detach();
      try? self.detachSubviews();
    };
  };
  
  // MARK: - Methods
  // ---------------
  
  func register(subviewToDetach subview: RNIContentViewParentDelegate){
    self.viewsToDetach.append(subview);
  };
  
  public func detach() throws {
    guard !self.didDetach else {
      throw RNIUtilitiesError(
        errorCode: .illegalState,
        description: "Already detached"
      );
    };
  
    guard let parentReactView = self.parentReactView else {
      throw RNIUtilitiesError(
        errorCode: .unexpectedNilValue,
        description: "Could not get parentReactView"
      );
    };
    
    self.dispatchEvent(for: .OnViewDidDetachFromParent, withPayload: [:]);
    
    #if RCT_NEW_ARCH_ENABLED
    parentReactView.setPositionType(.absolute);
    parentReactView.backgroundColor = .clear;
    self.alpha = 0.01;
    #else
    self.alpha = 0.01;
    parentReactView.removeFromSuperview();
    #endif
    
    self.didDetach = true;
  };
  
  public func detach(
    subview viewToDetach: RNIContentViewParentDelegate
  ) throws {
    
    let matchIndex = self.viewsToDetach.enumerated().first {
      $0.element === viewToDetach;
    };
    
    guard let matchIndex = matchIndex else {
      throw RNIUtilitiesError(
        errorCode: .guardCheckFailed,
        description: "Subview to detach does not exists in `viewsToDetach`"
      );
    };
    
    self.viewsToDetach.remove(at: matchIndex.offset);
    self.detachedViews.append(viewToDetach);
    
    viewToDetach.removeFromSuperview();
    viewToDetach.attachReactTouchHandler();
    
    self.dispatchEvent(for: .onContentViewDidDetach, withPayload: [:]);
  };
  
  public func detachSubviews() throws {
    guard self.hasViewsToDetach else {
      throw RNIUtilitiesError(
        errorCode: .illegalState,
        description: "There are no subviews to detach"
      );
    };
  
    try self.viewsToDetach.forEach {
      try self.detach(subview: $0);
    };
  };
};

// MARK: - RNIDetachedViewDelegate+RNIContentViewDelegate
// ------------------------------------------------------

extension RNIDetachedViewContent: RNIContentViewDelegate {

  public typealias KeyPathRoot = RNIDetachedViewContent;

  // MARK: Paper + Fabric
  // --------------------
    
  public func notifyOnMountChildComponentView(
    sender: RNIContentViewParentDelegate,
    childComponentView: UIView,
    index: NSInteger,
    superBlock: () -> Void
  ) {
  
    self.addSubview(childComponentView);
    
    if let viewToDetach = childComponentView as? RNIContentViewParentDelegate {
      self.register(subviewToDetach: viewToDetach);
      
      if self.shouldImmediatelyDetach {
        try? self.detach(subview: viewToDetach);
      };
    };
  };
  
  public func notifyOnUnmountChildComponentView(
    sender: RNIContentViewParentDelegate,
    childComponentView: UIView,
    index: NSInteger,
    superBlock: () -> Void
  ) {
    #if !RCT_NEW_ARCH_ENABLED
    superBlock();
    #else
    childComponentView.removeFromSuperview();
    #endif
  };
  
  public func notifyOnViewCommandRequest(
    sender: RNIContentViewParentDelegate,
    forCommandName commandName: String,
    withCommandArguments commandArguments: NSDictionary,
    resolve resolveBlock: (NSDictionary) -> Void,
    reject rejectBlock: (String) -> Void
  ) {
    
    do {
      guard let commandArguments = commandArguments as? Dictionary<String, Any> else {
        throw RNIUtilitiesError(errorCode: .guardCheckFailed);
      };
      
      switch commandName {
        case "attachToWindow":
          guard let window = UIApplication.shared.activeWindow else {
            throw RNIUtilitiesError(errorCode: .unexpectedNilValue);
          };
          
          let contentPositionConfig: AlignmentPositionConfig = try {
            let dictConfig = try commandArguments.getValueFromDictionary(
              forKey: "contentPositionConfig",
              type: Dictionary<String, Any>.self
            );
            
            return try .init(fromDict: dictConfig);
          }();
          
          try? self.detach();
          try? self.detachSubviews();
          
          guard let viewToDetach = self.detachedViews.first else {
            throw RNIUtilitiesError(errorCode: .unexpectedNilValue);
          };
            
          let childVC = RNIBaseViewController();
          childVC.rootReactView = viewToDetach;
          childVC.positionConfig = contentPositionConfig;
          
          let rootVC = window.rootViewController!;
          rootVC.view.addSubview(childVC.view);
          rootVC.addChild(childVC);
          childVC.didMove(toParent: rootVC);
          
          resolveBlock([:]);
          
        case "presentInModal":
          guard let window = UIApplication.shared.activeWindow else {
            throw RNIUtilitiesError(errorCode: .unexpectedNilValue);
          };
          
          try? self.detach();
          try? self.detachSubviews();
        
          guard let viewToDetach = self.detachedViews.first else {
            throw RNIUtilitiesError(errorCode: .unexpectedNilValue);
          };
          
          let contentPositionConfig: AlignmentPositionConfig = try {
            let dictConfig = try commandArguments.getValueFromDictionary(
              forKey: "contentPositionConfig",
              type: Dictionary<String, Any>.self
            );
            
            return try .init(fromDict: dictConfig);
          }();
          
          let modalVC = RNIBaseViewController();
          modalVC.rootReactView = viewToDetach;
          modalVC.positionConfig = contentPositionConfig;
          modalVC.view.backgroundColor = .systemGray;
          
          let rootVC = window.rootViewController!;
          rootVC.present(modalVC, animated: true);
          
          resolveBlock([:]);
        
        default:
          throw RNIUtilitiesError(errorCode: .invalidValue);
      };
    
    } catch {
      rejectBlock(error.localizedDescription);
    };
  };
  
  // MARK: Fabric Only
  // -----------------
  
  #if RCT_NEW_ARCH_ENABLED
  public func shouldRecycleContentDelegate(
    sender: RNIContentViewParentDelegate
  ) -> Bool {
    return false;
  };
  #endif
  
  // MARK: Paper Only
  // ----------------
  
  #if !RCT_NEW_ARCH_ENABLED
  public func notifyOnViewWillInvalidate(sender: RNIContentViewParentDelegate) {
    sender.allReactSubviews.forEach {
      $0.removeFromSuperview();
    };
  };
  #endif
};
