//
//  RNIBaseView.h
//  react-native-ios-utilities
//
//  Created by Dominic Go on 4/30/24.
//

#import <UIKit/UIKit.h>
#import "react-native-ios-utilities/RNIRegistrableView.h"

#if RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#else
#import <React/RCTView.h>
#endif

// MARK: - Forward Declarations
// ----------------------------

@protocol RNIContentViewParentDelegate;
@protocol RNIContentViewDelegate;

@class RNILayoutMetrics;

#if !RCT_NEW_ARCH_ENABLED
@class RCTBridge;
@class RCTShadowView;
@class RNIBaseViewEventHandler;
#endif

typedef NS_ENUM(NSInteger, RNIPositionType);

// MARK: - RNIBaseView
// -------------------

@interface RNIBaseView:
#if  RCT_NEW_ARCH_ENABLED
  RCTViewComponentView<RNIContentViewParentDelegate, RNIRegistrableView>
#else
  RCTView<RNIContentViewParentDelegate, RNIRegistrableView>
#endif

// MARK: - Properties - Fabric + Paper
// -----------------------------------

#if !RCT_NEW_ARCH_ENABLED
@property (nonatomic, strong, nullable) UIView *contentView;
#endif

@property (nonatomic, strong, nullable) NSObject<RNIContentViewDelegate> *contentDelegate;

@property (nonatomic, strong, nullable) RNILayoutMetrics *cachedLayoutMetrics;

// MARK: - Properties - Paper Only
// -------------------------------

#if !RCT_NEW_ARCH_ENABLED
@property (nonatomic, weak, nullable) RCTBridge *bridge;

@property (nonatomic, weak, nullable) RCTShadowView *cachedShadowView;

@property (nonatomic, strong, nonnull) RNIBaseViewEventHandler *reactEventHandler;
#endif

// MARK: - Init
// ------------

#if RCT_NEW_ARCH_ENABLED
- (nonnull instancetype)initWithFrame:(CGRect)frame;
#else
- (nonnull instancetype)initWithBridge:(nonnull RCTBridge *)bridge;
#endif

- (void) initCommon NS_REQUIRES_SUPER;

- (nonnull Class) viewDelegateClass;

// MARK: - RNIContentViewParentDelegate Commands
// ---------------------------------------------

- (void)setSize:(CGSize)size;

- (void)dispatchViewEventForEventName:(nonnull NSString *)eventName
                          withPayload:(nonnull NSDictionary *)eventPayload NS_SWIFT_NAME(dispatchViewEvent(forEventName:withPayload:));

#if RCT_NEW_ARCH_ENABLED
- (void)setPadding:(UIEdgeInsets)padding;

- (void)setPositionType:(RNIPositionType)positionType;
#endif
@end
