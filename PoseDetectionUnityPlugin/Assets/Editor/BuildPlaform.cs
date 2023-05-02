using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using System.IO;
using UnityEngine;

namespace PoseDetectionUnityPlugin.Assets.Editor
{
    public class BuildPlaform
    {
        [PostProcessBuild(1)]
        public static void AfterBuild(BuildTarget target, string pathToBuiltProject)
        {
            if(target == BuildTarget.iOS)
            {
                string projectPath = PBXProject.GetPBXProjectPath(pathToBuiltProject);
                PBXProject proj =  new PBXProject();
                string contents = File.ReadAllText(projectPath);
                proj.ReadFromString(contents);
                string unityTarget = proj.TargetGuidByName(PBXProject.GetUnityTargetName());
                proj.SetBuildProperty(unityTarget, "ENABLE_BITCODE","NO");
                proj.SetBuildProperty(unityTarget, "CLANG_ENABLE_MODULES","YES");
                File.WriteAllText(projectPath,proj.WriteToString());
            }
            
        }
        
    }
}