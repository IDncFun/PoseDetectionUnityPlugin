//
//  PoseDetectionSessionNative.h
//  Unity-iPhone
//
//  Created by Spacecycle on 2023/1/12.
//

#ifndef PoseDetectionSessionNative_h
#define PoseDetectionSessionNative_h

struct JointPoint {
    float X;
    float Y;
    bool Visible;
};

typedef enum : NSUInteger {
    Head = 0,
    Neck = 1,
    Torso = 2,
    LeftShoulder = 3,
    LeftElbow = 4,
    LeftHand = 5,
    RightShoulder = 6,
    RightElbow = 7,
    RightHand = 8,
    LeftHip = 9,
    LeftKnee = 10,
    LeftFoot = 11,
    RightHip = 12,
    RightKnee = 13,
    RightFoot = 14
} JointType;


struct BodyInfo{
    float Id;
    float KeyPointCount;
    struct JointPoint KeyPoints[15];
};

struct HumanAction{
    struct BodyInfo Bodys[1];
    int BodyCount;
};

struct UnityResult {
    int ImageWidth;
    int ImageHeight;
    struct HumanAction HumanAction;
};

struct DeviceRotateAxis{
    float X;
    float Y;
    float Z;
};

@interface PoseDetectionSessionNative : NSObject
@end

#endif /* PoseDetectionSessionNative_h */
