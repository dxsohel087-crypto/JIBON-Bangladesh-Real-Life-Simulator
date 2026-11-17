#if UNITY_EDITOR
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

public static class JibonRunnerBuild
{
    public static void BuildAndroid()
    {
        JibonRunnerProjectSetup.CreateStarterScene();
        EditorUserBuildSettings.buildAppBundle = false;
        PlayerSettings.productName = "JIBON RUNNER";
        PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.sohelrana.jibonrunner");
        PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel23;

        string[] scenes = EditorBuildSettings.scenes.Where(scene => scene.enabled).Select(scene => scene.path).ToArray();
        if (scenes.Length == 0) throw new System.Exception("No enabled scenes found for JIBON RUNNER.");

        BuildPlayerOptions options = new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = "Build/Android/JIBON-RUNNER.apk",
            target = BuildTarget.Android,
            options = BuildOptions.None
        };

        BuildReport report = BuildPipeline.BuildPlayer(options);
        if (report.summary.result != BuildResult.Succeeded)
            throw new System.Exception("JIBON RUNNER Android build failed: " + report.summary.result);
        Debug.Log("JIBON RUNNER APK created: " + options.locationPathName);
    }
}
#endif
