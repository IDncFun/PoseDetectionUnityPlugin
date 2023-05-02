using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PoseDetectionUnityPlugin;
using UnityEngine.UI;

public class PoseDetectionExample : MonoBehaviour {

	private PoseDetection poseDetection;
	[SerializeField] private RawImage cameraImg;
	[SerializeField] private RawImage jointImg;
	private List<RawImage> jointImgs;
	// Use this for initialization
	void Start () {
		poseDetection = new PoseDetection(cameraImg);
		cameraImg.texture = poseDetection.ColorTexture;
		cameraImg.rectTransform.localScale =  poseDetection.ColorTextureScale;
		poseDetection.StartPreview();
		jointImgs = new List<RawImage>();
		for(int i = 0; i < 15; i++){
			var jointClone = GameObject.Instantiate(jointImg.gameObject);
			jointClone.transform.SetParent(jointImg.rectTransform.parent);
			jointClone.transform.localScale = jointImg.rectTransform.localScale;
			jointImgs.Add(jointClone.GetComponent<RawImage>());
		}

		jointImg.gameObject.SetActive(false);
	}
	
	// Update is called once per frame
	void Update () {
		poseDetection.Update();
		Vector2[] points = poseDetection.JointsToCanvasPoints(poseDetection.KeyPoints, (int)cameraImg.rectTransform.sizeDelta.x, (int)cameraImg.rectTransform.sizeDelta.y);
		for(int i = 0; i < jointImgs.Count; i++){
			jointImgs[i].rectTransform.anchoredPosition3D = new Vector3(points[i].x,points[i].y,0);
		}
	}

	private void OnApplicationQuit() {
		poseDetection.StopPreview();
	}	
}
