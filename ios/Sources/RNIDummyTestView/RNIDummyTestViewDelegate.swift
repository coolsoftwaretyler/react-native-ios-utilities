//
//  RNIDummyTestViewDelegate.swift
//  react-native-ios-utilities
//
//  Created by Dominic Go on 5/12/24.
//

import UIKit
import DGSwiftUtilities

@objc
public final class RNIDummyTestViewDelegate: UIView, RNIContentView {
  
  // MARK: StringKeyPathMapping
  // --------------------------
  
  public static var partialKeyPathMap: Dictionary<String, PartialKeyPath<RNIDummyTestViewDelegate>> {
    return [
      "someBool": \.someBool,
      "someString": \.someString,
      "someStringOptional": \.someStringOptional,
      "someNumber": \.someNumber,
      "someNumberOptional": \.someNumberOptional,
      "someObject": \.someObject,
      "someObjectOptional": \.someObjectOptional,
      "someArray": \.someArray,
      "someArrayOptional": \.someArrayOptional,
    ];
  };
  
  // MARK: - Properties - RNIContentViewDelegate
  // -------------------------------------------
  
  public weak var parentReactView: RNIContentViewParentDelegate?;
  
  #if RCT_NEW_ARCH_ENABLED
  public var reactProps: NSDictionary = [:];
  #endif
  
  // MARK: Props
  // -----------
  
  @objc
  public var someBool: Bool = false {
    willSet {
      print("RNIDummyTestViewDelegate.someBool - newValue:", newValue);
    }
  };
  
  @objc
  public var someString: String = "";
  
  @objc
  public var someStringOptional: String?;
  
  @objc
  public var someNumber: NSNumber = -1;
  
  @objc
  public var someNumberOptional: NSNumber?;
  
  @objc
  public var someObject: NSDictionary = [:];
  
  @objc
  public var someObjectOptional: NSDictionary?;
  
  @objc
  public var someArray: NSArray = [];
  
  @objc
  public var someArrayOptional: NSArray?;
  
  // MARK: Init
  // ----------
  
  public override init(frame: CGRect) {
    super.init(frame: frame);
  };
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented");
  }
  
  // MARK: Functions
  // ---------------
  
  public override func didMoveToWindow() {
    guard self.window != nil,
          let parentReactView = self.parentReactView
    else { return };
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 10){
      parentReactView.setSize(.init(width: 300, height: 300));
    };
  };
  
  func _setupContent(){
    self.backgroundColor = .systemPink;
  
    let label = UILabel();
    label.text = "Fabric View (sort of) in Swift";
    
    label.translatesAutoresizingMaskIntoConstraints = false;
    self.addSubview(label);
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(
        equalTo: self.centerXAnchor
      ),
      label.centerYAnchor.constraint(
        equalTo: self.centerYAnchor
      ),
    ]);
  };
};

extension RNIDummyTestViewDelegate: RNIContentViewDelegate {

  public typealias KeyPathRoot = RNIDummyTestViewDelegate;

  // MARK: Paper + Fabric
  // --------------------
  
  public func notifyOnInit(sender: RNIContentViewParentDelegate) {
    self._setupContent();
  };
    
  public func notifyOnMountChildComponentView(
    sender: RNIContentViewParentDelegate,
    childComponentView: UIView,
    index: NSInteger,
    superBlock: () -> Void
  ) {
    #if !RCT_NEW_ARCH_ENABLED
    superBlock();
    #endif
    
    let eventPayload: [String: Any] = [
      "someBool": true,
      "someString": "abc",
      "someNumber": 123,
      "someObject": [
        "someBool": true,
        "someString": "abc",
      ],
      "someArray": [],
    ];
    
    sender.dispatchViewEvent(
      forEventName: "onSomeDirectEventWithEmptyPayload",
      withPayload: [:]
    );
    
    sender.dispatchViewEvent(
      forEventName: "onSomeDirectEventWithObjectPayload",
      withPayload: eventPayload
    );
    
    sender.dispatchViewEvent(
      forEventName: "onSomeBubblingEventWithEmptyPayload",
      withPayload: [:]
    );
    
    sender.dispatchViewEvent(
      forEventName: "onSomeBubblingEventWithObjectPayload",
      withPayload: eventPayload
    );
    
    self.reactGetLayoutMetrics {
      print(
        "RNIDummyTestViewDelegate.notifyOnMountChildComponentView",
        "\n - childComponentView.reactGetLayoutMetrics:", $0?.description ?? "N/A",
        "\n"
      );
    };
    
    print(
      "RNIDummyTestViewDelegate.notifyOnMountChildComponentView",
      "\n - childComponentView:", childComponentView.debugDescription,
      "\n - childComponentView.reactNativeTag:", childComponentView.reactNativeTag?.stringValue ?? "N/A",
      "\n - childComponentView.reactNativeID:", childComponentView.reactNativeID ?? "N/A",
      "\n - index:", index,
      "\n - sender.window:", sender.window?.debugDescription ?? "N/A",
      "\n - self.window:", self.window?.debugDescription ?? "N/A",
      "\n"
    );
    
    // Note: Window might not be available yet
    self.addSubview(childComponentView);
  };
  
  public func notifyOnUnmountChildComponentView(
    sender: RNIContentViewParentDelegate,
    childComponentView: UIView,
    index: NSInteger,
    superBlock: () -> Void
  ) {
    #if !RCT_NEW_ARCH_ENABLED
    superBlock();
    #endif
    
    childComponentView.removeFromSuperview();
    
    print(
      "RNIDummyTestViewDelegate.notifyOnUnmountChildComponentView",
      "\n - childComponentView:", childComponentView.debugDescription,
      "\n - index:", index,
      "\n - self.window:", self.window?.debugDescription ?? "N/A",
      "\n"
    );
  }
  
  public func notifyDidSetProps(sender: RNIContentViewParentDelegate) {
    print(
      "RNIDummyTestViewDelegate.notifyDidSetProps",
      "\n - someBool:", self.someBool,
      "\n - someString:", self.someString,
      "\n - someStringOptional:", self.someStringOptional.debugDescription,
      "\n - someNumber:", self.someNumber,
      "\n - someNumberOptional:", self.someNumberOptional.debugDescription,
      "\n - someObject:", self.someObject,
      "\n - someObjectOptional:", self.someObjectOptional.debugDescription,
      "\n - someArray:", self.someArray,
      "\n - someArrayOptional:", self.someArrayOptional.debugDescription,
      "\n"
    );
  };
  
  public func notifyOnUpdateLayoutMetrics(
    sender: RNIContentViewParentDelegate,
    oldLayoutMetrics: RNILayoutMetrics,
    newLayoutMetrics: RNILayoutMetrics
  ) {
    #if RN_FABRIC_ENABLED
    print("Hello Fabric");
    #else
    print("Hello Paper");
    #endif
    
    print(
      "RNIDummyTestViewDelegate.notifyOnUpdateLayoutMetrics",
      "\n - oldLayoutMetric.frame:", oldLayoutMetrics.frame,
      "\n - oldLayoutMetric.frame:", newLayoutMetrics.frame,
      "\n - self.reactNativeTag:", self.reactNativeTag?.stringValue ?? "N/A",
      "\n - sender.reactNativeTag:", sender.reactNativeTag?.stringValue ?? "N/A",
      "\n - sender.window:", sender.window?.debugDescription ?? "N/A",
      "\n - self.window:", self.window?.debugDescription ?? "N/A",
      "\n"
    );
  };
  
  public func notifyOnViewCommandRequest(
    sender: RNIContentViewParentDelegate,
    forCommandName commandName: String,
    withCommandArguments commandArguments: NSDictionary,
    resolve resolveBlock: (NSDictionary) -> Void,
    reject rejectBlock: (String) -> Void
  ) {
  
    print(
      "RNIDummyTestViewDelegate.notifyOnViewCommandRequest",
      "\n - commandName:", commandName,
      "\n - commandArguments.count:", commandArguments.count,
      "\n - commandArguments.keys:", commandArguments.allKeys,
      "\n - commandArguments:", commandArguments,
      "\n"
    );
    
    resolveBlock([
      "someString": "abc",
      "someInt": 123,
      "someDouble": 3.14,
      "someBool": true
    ]);
  };
  
  // MARK: Fabric Only
  // -----------------

  #if RCT_NEW_ARCH_ENABLED
  public func notifyOnUpdateProps(
    sender: RNIContentViewParentDelegate,
    oldProps: NSDictionary,
    newProps: NSDictionary
  ) {
    print(
      "RNIDummyTestViewDelegate.notifyOnUpdateProps",
      "\n - oldProps:", oldProps.debugDescription,
      "\n - newProps:", newProps,
      "\n"
    );
  };
  
  public func notifyOnUpdateState(
    sender: RNIContentViewParentDelegate,
    oldState: NSDictionary?,
    newState: NSDictionary
  ) {
    print(
      "RNIDummyTestViewDelegate.notifyOnUpdateState",
      "\n - oldState:", oldState.debugDescription,
      "\n - newState:", newState,
      "\n"
    );
  };
  
  public func notifyOnFinalizeUpdates(
    sender: RNIContentViewParentDelegate,
    updateMaskRaw: Int,
    updateMask: RNIComponentViewUpdateMask
  ) {
    
    print(
      "RNIDummyTestViewDelegate.notifyOnFinalizeUpdates",
      "\n - updateMaskRaw:", updateMaskRaw,
      "\n - updateMask.contains(.eventEmitter):", updateMask.contains(.eventEmitter),
      "\n - updateMask.contains(.layoutMetrics):", updateMask.contains(.layoutMetrics),
      "\n - updateMask.contains(.props):", updateMask.contains(.props),
      "\n - updateMask.contains(.state):", updateMask.contains(.state),
      "\n - updateMask.contains(.all):", updateMask.contains(.all),
      "\n - updateMask.isNone:", updateMask.isNone,
      "\n"
    );
  };
  
  public func notifyOnPrepareForReuse(sender: RNIContentViewParentDelegate) {
    print(
      "RNIDummyTestViewDelegate.notifyOnPrepareForReuse"
    );
  };
  #else
  
  // MARK: - Paper Only
  // ------------------
  
  #endif
};
