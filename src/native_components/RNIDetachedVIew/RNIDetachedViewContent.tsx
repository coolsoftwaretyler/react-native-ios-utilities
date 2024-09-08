import * as React from 'react';
import { StyleSheet, View, type StyleProp, type ViewStyle } from 'react-native';

import { RNIWrapperView } from '../RNIWrapperView';
import { IS_USING_NEW_ARCH } from '../../constants/LibEnv';
import type { RNIDetachedViewContentProps } from './RNIDetachedViewContentTypes';


export function RNIDetachedViewContent(
  props: React.PropsWithChildren<RNIDetachedViewContentProps>
) {
  const wrapperStyle: StyleProp<ViewStyle> = [
    styles.wrapperView,
    props.shouldEnableDebugBackgroundColors && styles.wrapperViewDebug,
    props.contentContainerStyle,
  ];

  return (
    <RNIWrapperView
      {...props}
      style={[
        props.style,
        ...(IS_USING_NEW_ARCH 
          ? wrapperStyle 
          : []
        ),
      ]}
    >
      {IS_USING_NEW_ARCH ? (
        props.children
      ) : (
        <View style={wrapperStyle}>
          {props.children}
        </View>
      )}
    </RNIWrapperView>
  );
};

const styles = StyleSheet.create({
  wrapperView: {
    flex: 1,
  },
  wrapperViewDebug: {
    backgroundColor: 'rgba(0,0,255,0.3)',
  },
  wrapperContentContainer: {
    flex: 1,
    alignSelf: 'stretch',
  },
});