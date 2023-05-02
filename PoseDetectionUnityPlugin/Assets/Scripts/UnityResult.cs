using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

namespace PoseDetectionUnityPlugin
{
    [StructLayout(LayoutKind.Sequential)]
    public struct JointPoint
    {
        public float X;
        public float Y;
        public bool Visible;
    };

    public enum JointType : int
    {
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
    };


    [StructLayout(LayoutKind.Sequential)]
    public struct BodyInfo
    {
        public float Id;
        public float KeyPointCount;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 15)]
        public JointPoint[] KeyPoints;
    };

    [StructLayout(LayoutKind.Sequential)]
    public struct HumanAction
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 1)]
        public BodyInfo[] Bodys;
        public int BodyCount;
    };

    [StructLayout(LayoutKind.Sequential)]
    public struct UnityResult
    {
        public int ImageWidth;
        public int ImageHeight;
        public HumanAction HumanAction;
    };

    [StructLayout(LayoutKind.Sequential)]
    public struct DeviceRotateAxis
    {
        public float X;
        public float Y;
        public float Z;
    }
}

