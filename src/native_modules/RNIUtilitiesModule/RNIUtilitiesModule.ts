import { default as NativeRNIUtilitiesModule } from './NativeRNIUtilitiesModule';

// modules are lazily loaded, so "reading" it's value triggers 
// the module to load in the native side.
NativeRNIUtilitiesModule;

const RNIUtilitiesModuleName = "RNIUtilitiesModule";
const RNIUtilitiesModule = (global as any)[RNIUtilitiesModuleName];

type SupportedNativePrimitiveValue = 
  | string
  | number
  | boolean;

type SupportedNativeValue = 
  | SupportedNativePrimitiveValue
  | Record<string, SupportedNativePrimitiveValue>
  | Array<SupportedNativePrimitiveValue>;

type SharedNativeValueMap = Record<string, SupportedNativeValue>;

async function viewCommandRequest<T = Record<string, unknown>>(
  viewID: string,
  commandName: string,
  commandArgs: Record<string, any>
): Promise<T> {

  if(RNIUtilitiesModule == null){
    throw "RNIUtilitiesModule is null";
  };

  if(RNIUtilitiesModule.viewCommandRequest == null){
    throw "RNIUtilitiesModule.viewCommandRequest is null";
  };

  return await RNIUtilitiesModule.viewCommandRequest(
    viewID,
    commandName,
    commandArgs
  );
};

async function moduleCommandRequest<T = Record<string, unknown>>(
  moduleName: string,
  commandName: string,
  commandArgs: Record<string, any>
): Promise<T> {

  if(RNIUtilitiesModule == null){
    throw "RNIUtilitiesModule is null";
  };

  if(RNIUtilitiesModule.moduleCommandRequest == null){
    throw "RNIUtilitiesModule.moduleCommandRequest is null";
  };

  return await RNIUtilitiesModule.moduleCommandRequest(
    moduleName,
    commandName,
    commandArgs
  );
};

export function getModuleSharedValue(
  moduleName: string,
  key: string,
): SupportedNativeValue{
  if(RNIUtilitiesModule == null){
    throw "RNIUtilitiesModule is null";
  };

  if(RNIUtilitiesModule.getModuleSharedValue == null){
    throw "RNIUtilitiesModule.getModuleSharedValue is null";
  };

  return RNIUtilitiesModule.getModuleSharedValue(moduleName, key);
};
export default {
  viewCommandRequest,
  moduleCommandRequest,
  getModuleSharedValue
};