using System;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.Universal;

// Run this temporary editor script in the sibling game's Unity project.
// Opens the saved scene, renders a separate camera with the original framing, and never saves it.
public static class MobileTableBackgroundExport
{
    public static void Capture()
    {
        string output = Argument("-backgroundOutput");
        if (string.IsNullOrEmpty(output))
            throw new ArgumentException("Pass -backgroundOutput /absolute/path/mesa.jpg");
        EditorSceneManager.OpenScene("Assets/Scenes/FatFish.unity");
        // The saved scene still has the old track. Build the same bowl and rotor
        // that TableSceneInstaller installs when the player starts the game.
        var wheel = UnityEngine.Object.FindAnyObjectByType<RouletteWhee>();
        if (wheel == null) throw new InvalidOperationException("The table scene needs its roulette wheel.");
        var builder = RouletteWheelBuilder.BuildFor(wheel);
        if (!builder.Ready) throw new InvalidOperationException("The runtime roulette could not be built.");
        foreach (var ball in UnityEngine.Object.FindObjectsByType<RouletteBall>(FindObjectsInactive.Exclude))
            ball.ResetBall();
        if (wheel.transform.parent.Find("RouletteBowl") == null || wheel.transform.Find("RotorDetail") == null)
            throw new InvalidOperationException("The exported scene is missing the runtime bowl or rotor.");
        Debug.Log("MOBILE_BACKGROUND_RUNTIME_ROULETTE_READY");
        foreach (var canvas in UnityEngine.Object.FindObjectsByType<Canvas>(FindObjectsSortMode.None))
            canvas.gameObject.SetActive(false);
        var source = Camera.main;
        if (source == null) throw new InvalidOperationException("The table scene needs its Main Camera.");
        foreach (var existing in UnityEngine.Object.FindObjectsByType<Camera>(FindObjectsSortMode.None))
            existing.enabled = false;
        var cameraObject = new GameObject("Mobile background export camera");
        var camera = cameraObject.AddComponent<Camera>();
        camera.CopyFrom(source);
        camera.transform.position = source.transform.position;
        camera.transform.rotation = source.transform.rotation;
        camera.GetUniversalAdditionalCameraData().renderPostProcessing = true;
        var target = new RenderTexture(1600, 900, 24, RenderTextureFormat.ARGB32);
        var image = new Texture2D(1600, 900, TextureFormat.RGB24, false);
        var previous = RenderTexture.active;
        try
        {
            target.Create();
            camera.targetTexture = target;
            camera.aspect = 1600f / 900f;
            // Warm up the renderer so imported materials and room textures are ready.
            for (int frame = 0; frame < 4; frame++) camera.Render();
            RenderTexture.active = target;
            image.ReadPixels(new Rect(0, 0, 1600, 900), 0, 0);
            image.Apply();
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(output)));
            File.WriteAllBytes(output, image.EncodeToJPG(92));
            Debug.Log("MOBILE_BACKGROUND_EXPORTED " + Path.GetFullPath(output));
        }
        finally
        {
            RenderTexture.active = previous;
            camera.targetTexture = null;
            UnityEngine.Object.DestroyImmediate(image);
            UnityEngine.Object.DestroyImmediate(target);
            UnityEngine.Object.DestroyImmediate(cameraObject);
        }
    }

    static string Argument(string name)
    {
        var args = Environment.GetCommandLineArgs();
        for (int i = 0; i + 1 < args.Length; i++)
            if (args[i] == name) return args[i + 1];
        return null;
    }
}
