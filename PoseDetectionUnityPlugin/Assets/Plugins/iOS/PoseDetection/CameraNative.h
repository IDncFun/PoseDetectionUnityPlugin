//
//  CameraNative.h
//  Unity-iPhone
//
//  Created by Spacecycle on 2023/2/14.
//
#include "CameraDelegate.h"
#ifndef CameraNative_h
#define CameraNative_h


@interface CameraNative : NSObject
-(void) setUpCamera;
-(void) startSession;
-(void) stopPreview;
-(void) addDelegate:(id<STCameraDelegate>) d;
-(int) getWidth;
-(int) getHeight;
+(GLuint) sharedNativeTexture;
+(id<MTLTexture>) sharedMetalNativeTexture;
@end
#endif /* CameraNative_h */
