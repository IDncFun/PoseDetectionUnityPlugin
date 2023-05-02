//
//  CameraDelegate.h
//  IOSCameraNative
//
//  Created by Spacecycle on 2023/2/14.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#ifndef CameraDelegate_h
#define CameraDelegate_h

@protocol STCameraDelegate <NSObject>

// call back in bufferQueue
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end


#endif /* CameraDelegate_h */
