#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
public static class JibonRunnerProjectSetup
{
    [MenuItem("JIBON RUNNER/Create Starter Scene")]
    public static void CreateStarterScene()
    {
        if (!AssetDatabase.IsValidFolder("Assets/Scenes")) AssetDatabase.CreateFolder("Assets", "Scenes");
        Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        new GameObject("JIBON RUNNER Runtime World").AddComponent<JibonRunnerBootstrap>();
        EditorSceneManager.SaveScene(scene, "Assets/Scenes/JibonRunner.unity");
        EditorBuildSettings.scenes = new[] { new EditorBuildSettingsScene("Assets/Scenes/JibonRunner.unity", true) };
        PlayerSettings.productName = "JIBON RUNNER";
        PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.sohelrana.jibonrunner");
        AssetDatabase.SaveAssets();
        Debug.Log("Starter scene created: Assets/Scenes/JibonRunner.unity");
    }
}
#endif
