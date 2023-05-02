//
//  PoseDetectionSessionNative.m
//  Unity-iPhone
//
//  Created by Spacecycle on 2023/1/12.
//

#import <Foundation/Foundation.h>
#import "CameraDelegate.h"
#import "PoseDetectionSessionNative.h"
#import <OpenGLES/ES2/glext.h>
#include "UnityMetalSupport.h"
#include "CameraNative.h"
#include "CoreMotion/CoreMotion.h"
@import MLKit;
@import MLImage;

static struct UnityResult unityResult;
static struct DeviceRotateAxis deviceRotateAxis;
@interface PoseDetectionSessionNative() <STCameraDelegate>
@property(nonatomic,strong) CameraNative *camera;
@property(nonatomic,strong) MLKPoseDetector *poseDetector;
@end

@implementation PoseDetectionSessionNative

-(instancetype) init{
    self = [super init];
    _camera = [[CameraNative alloc] init];
    [_camera setUpCamera];
    [_camera addDelegate:self];
    
    [self setUpPoseDetector];
    [self startMotionUpdate];
    return self;
}

-(void) startMotionUpdate{
    CMMotionManager *motionMananger = [[CMMotionManager alloc] init];
    NSOperationQueue *optQueue = [[NSOperationQueue alloc]init];
    if(motionMananger.accelerometerAvailable){
        motionMananger.accelerometerUpdateInterval = 1.0;
        [motionMananger startAccelerometerUpdatesToQueue:optQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if(error){
                [motionMananger stopAccelerometerUpdates];
            }
            else{
                deviceRotateAxis.X = accelerometerData.acceleration.x;
                deviceRotateAxis.Y = accelerometerData.acceleration.y;
                deviceRotateAxis.Z = accelerometerData.acceleration.z;
            }
        }];
        
    }
    else
    {
        NSLog(@"The device doesn't support getting acceleration data");
        if([motionMananger isGyroAvailable]){
            motionMananger.gyroUpdateInterval = 1.0;
            [motionMananger startGyroUpdatesToQueue:optQueue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
                if(error){
                    [motionMananger stopGyroUpdates];
                }
                else
                {
                    deviceRotateAxis.X = gyroData.rotationRate.x;
                    deviceRotateAxis.Y = gyroData.rotationRate.y;
                    deviceRotateAxis.Z = gyroData.rotationRate.z;
                }
            }];
        }
    }
}

-(void) setUpPoseDetector{
    MLKAccuratePoseDetectorOptions *options = [[MLKAccuratePoseDetectorOptions alloc] init];
    options.detectorMode = MLKPoseDetectorModeStream;
    _poseDetector = [MLKPoseDetector poseDetectorWithOptions:options];
}

-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    [self detectProcess:sampleBuffer];
}

-(void) detectProcess:(CMSampleBufferRef)sampleBuffer{
    MLKVisionImage *image = [[MLKVisionImage alloc] initWithBuffer:sampleBuffer];
    NSError *error;
    NSArray *detectedPoses = [self.poseDetector resultsInImage:image error:&error];
    
    if(error != nil){
        return;
    }

    if(detectedPoses.count == 0){
        unityResult.HumanAction.BodyCount = 0;
        return;
    }
    
    unityResult.HumanAction.BodyCount = (int)detectedPoses.count;
    for( MLKPose *pose in detectedPoses){
        struct BodyInfo body;
        [self UpdatePoint:&body.KeyPoints[Head] :[pose landmarkOfType:MLKPoseLandmarkTypeNose].position:[pose landmarkOfType:MLKPoseLandmarkTypeNose].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[LeftShoulder] :[pose landmarkOfType:MLKPoseLandmarkTypeLeftShoulder].position:[pose landmarkOfType:MLKPoseLandmarkTypeLeftShoulder].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[LeftElbow] :[pose landmarkOfType:MLKPoseLandmarkTypeLeftElbow].position:[pose landmarkOfType:MLKPoseLandmarkTypeLeftElbow].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[LeftHand] :[pose landmarkOfType:MLKPoseLandmarkTypeLeftWrist].position:[pose landmarkOfType:MLKPoseLandmarkTypeLeftWrist].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[RightShoulder] :[pose landmarkOfType:MLKPoseLandmarkTypeRightShoulder].position:[pose landmarkOfType:MLKPoseLandmarkTypeRightShoulder].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[RightElbow] :[pose landmarkOfType:MLKPoseLandmarkTypeRightElbow].position:[pose landmarkOfType:MLKPoseLandmarkTypeRightElbow].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[RightHand] :[pose landmarkOfType:MLKPoseLandmarkTypeRightWrist].position:[pose landmarkOfType:MLKPoseLandmarkTypeRightWrist].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[LeftHip] :[pose landmarkOfType:MLKPoseLandmarkTypeLeftHip].position:[pose landmarkOfType:MLKPoseLandmarkTypeLeftHip].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[LeftKnee] :[pose landmarkOfType:MLKPoseLandmarkTypeLeftKnee].position:[pose landmarkOfType:MLKPoseLandmarkTypeLeftKnee].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[LeftFoot] :[pose landmarkOfType:MLKPoseLandmarkTypeLeftAnkle].position:[pose landmarkOfType:MLKPoseLandmarkTypeLeftAnkle].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[RightHip] :[pose landmarkOfType:MLKPoseLandmarkTypeRightHip].position:[pose landmarkOfType:MLKPoseLandmarkTypeRightHip].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[RightKnee] :[pose landmarkOfType:MLKPoseLandmarkTypeRightKnee].position:[pose landmarkOfType:MLKPoseLandmarkTypeLeftKnee].inFrameLikelihood];
        [self UpdatePoint:&body.KeyPoints[RightFoot] :[pose landmarkOfType:MLKPoseLandmarkTypeRightAnkle].position:[pose landmarkOfType:MLKPoseLandmarkTypeRightAnkle].inFrameLikelihood];
        body.KeyPoints[Neck].X = (body.KeyPoints[LeftShoulder].X + body.KeyPoints[RightShoulder].X) / 2;
        body.KeyPoints[Neck].Y = (body.KeyPoints[LeftShoulder].Y + body.KeyPoints[RightShoulder].Y) / 2;
        body.KeyPoints[Neck].Visible = true;
        body.KeyPoints[Torso].X = (body.KeyPoints[LeftShoulder].X + body.KeyPoints[RightShoulder].X + body.KeyPoints[LeftHip].X + body.KeyPoints[RightHip].X) / 4;
        body.KeyPoints[Torso].Y = (body.KeyPoints[LeftShoulder].Y + body.KeyPoints[RightShoulder].Y + body.KeyPoints[LeftHip].Y + body.KeyPoints[RightHip].Y) / 4;
        body.KeyPoints[Torso].Visible = true;
        unityResult.HumanAction.Bodys[0] = body;
        unityResult.ImageWidth = [_camera getWidth];
        unityResult.ImageHeight = [_camera getHeight];
    }
}


-(void)UpdatePoint:(struct JointPoint*) mypoint :(MLKVision3DPoint *) stPoint :(float) pointScore
{
    mypoint->X = stPoint.x;
    mypoint->Y = stPoint.y;
    mypoint->Visible = pointScore > 0.5;
}

char* makeStringCopy(const char* string)
{
    if (NULL == string) {
        return NULL;
    }
    char* res = (char*)malloc(strlen(string)+1);
    strcpy(res, string);
    return res;
}

@end

void* unity_CreatePoseDetectionSession(){
    
    PoseDetectionSessionNative *session;
    session = [[PoseDetectionSessionNative alloc] init];
    return (__bridge_retained void*)session;
}

void session_StartSession(const void* session){
    PoseDetectionSessionNative *nativeSession = (__bridge PoseDetectionSessionNative *)session;
    [nativeSession.camera startSession];
}

void  session_StopSession(const void* session){
    PoseDetectionSessionNative *nativeSession = (__bridge PoseDetectionSessionNative *)session;
    [nativeSession.camera stopPreview];
}

struct UnityResult GetPoseDetectionResult(){
    return unityResult;
}

char* session_GetPoseDetectionResult(const void* session){
    return "";
}

struct DeviceRotateAxis GetDeviceRotateAxis(){
    return deviceRotateAxis;
}
