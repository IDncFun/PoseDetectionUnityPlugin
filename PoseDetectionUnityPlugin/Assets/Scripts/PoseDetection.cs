using System.Globalization;
using System.Security.AccessControl;
using System.Diagnostics;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.UI;

namespace PoseDetectionUnityPlugin{

	public struct CameraTextureInfo
	{
            public IntPtr native;
            public int width;
            public int height;
            public int format;
            public int flipped;
    }

	public class PoseDetection  {
#if UNITY_IOS && !UNITY_EDITOR
			[DllImport("__Internal")]
			private static extern IntPtr unity_CreatePoseDetectionSession();
			[DllImport("__Internal")]
			private static extern void session_StartSession(IntPtr session);
			[DllImport("__Internal")]
			private static extern void session_StopSession(IntPtr session);
			[DllImport("__Internal")]
			private static extern string session_GetPoseDetectionResult(IntPtr session);
			[DllImport("__Internal")]
			private static extern UnityResult GetPoseDetectionResult();
			[DllImport("__Internal")]
			private static extern CameraTextureInfo GetCameraTextureInfo();
			[DllImport("__Internal")]
			private static extern DeviceRotateAxis GetDeviceRotateAxis();
#endif
		public Texture2D ColorTexture;
		private IntPtr nativePoseDetectionSession;
		private Vector3 colorTextureScale = Vector3.one;
		private IntPtr externalTextureId;
		private int width = 640;
        private int height = 480;
		private bool running = false;
		private JointPoint[] keyPoints;
		private RawImage cameraImage;

		public JointPoint[] KeyPoints
		{
			get
			{
				return keyPoints;
			}
		}


		public Vector3 ColorTextureScale{
			get{
				return colorTextureScale;
			}
		}

		public PoseDetection(RawImage cameraImage){
#if UNITY_IOS && !UNITY_EDITOR
			this.nativePoseDetectionSession = unity_CreatePoseDetectionSession();
#endif
			this.cameraImage = cameraImage;
		}

		public void StartPreview()
        {
#if UNITY_IOS && !UNITY_EDITOR
            session_StartSession(nativePoseDetectionSession);
#endif
			running = true;
        }

		public void StopPreview()
        {
#if UNITY_IOS && !UNITY_EDITOR
            session_StopSession(nativePoseDetectionSession);
#endif
			running = false;
        }

		public void Update(){
			if(running){
				UpdateColorTexture();
				UpdateJoints();
			}
		}

		private void UpdateJoints(){
#if UNITY_IOS && !UNITY_EDITOR
			UnityResult result = GetPoseDetectionResult();
			width = result.ImageWidth;
			height = result.ImageHeight;
			var jointCount = result.HumanAction.BodyCount;
			UnityEngine.Debug.Log("[UpdateJoints] jointCount:" + jointCount);
			float mainBodyId = 0;
			if (jointCount > 0)
			{
				BodyInfo first  = result.HumanAction.Bodys.FirstOrDefault();
				UnityEngine.Debug.Log(first.KeyPointCount);
				keyPoints = first.KeyPoints;
				mainBodyId = first.Id;
			}
#endif
		}

		public Vector2[] JointsToCanvasPoints(JointPoint[] joints, int width, int height)
        {
			Vector2[] points = new Vector2[15];
			if(joints != null)
			{
				float scaleX = (float)width / this.width;
				float scaleY = (float)height / this.height;
				
				for (int i = 0; i < joints.Length; i++)
				{
					var joint = joints[i];
					if (joint.Visible)
					{
						points[i].x = (int)(joint.X * scaleX);
						points[i].y = (int)(joint.Y * scaleY);
					}
				}
			}
            

			return points;
        }

		private void UpdateColorTexture(){
#if UNITY_IOS && !UNITY_EDITOR
            CameraTextureInfo textureInfo = GetCameraTextureInfo();
            var w = textureInfo.width;
            var h = textureInfo.height;
            var textureId = textureInfo.native;
            if(this.ColorTexture == null )
            {
                if (textureId != IntPtr.Zero)
                {
                    this.ColorTexture = Texture2D.CreateExternalTexture(w, h, TextureFormat.BGRA32, false, false, (IntPtr)textureId);
                    this.width = w;
                    this.height = h;
                    externalTextureId = textureId;
					this.cameraImage.texture = this.ColorTexture;
                }
            }
            else if (externalTextureId != textureId)
            {
                if (w != width || h != height)
                {
                    this.ColorTexture.Resize(w, h);
                    width = w;
                    height = h;
                }

                this.ColorTexture.UpdateExternalTexture((IntPtr)textureId);
                externalTextureId = textureId;
            }
#endif
		}
	}
}

