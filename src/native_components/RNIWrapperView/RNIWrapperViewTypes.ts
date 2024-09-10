import type { PropsWithChildren } from "react";
import type { ViewProps } from "react-native";

import type { RNIWrapperNativeViewProps } from "./RNIWrapperNativeView";
import type { StateReactTag, StateViewID } from '../../types/SharedStateTypes';


export type RNIWrapperViewRef = {
  getViewID: () => StateViewID;
  getReactTag: () => StateReactTag;
};

export type RNIWrapperViewInheritedOptionalProps = Partial<Pick<RNIWrapperNativeViewProps,
  | 'onDidSetViewID'
  | 'onViewWillRecycle'
>>;

// export type RNIWrapperViewInheritedRequiredProps = Required<Pick<RNIWrapperNativeViewProps,
//   | 'placeholder'
// >>;

export type RNIWrapperViewInheritedProps =
    RNIWrapperViewInheritedOptionalProps;
//  & RNIWrapperViewInheritedRequiredProps;

export type RNIWrapperViewBaseProps = {
  // TBA
  debugShouldEnableLogging?: boolean;
};

export type RNIWrapperViewProps = PropsWithChildren<
    RNIWrapperViewInheritedProps 
  & RNIWrapperViewBaseProps
  & ViewProps
>;