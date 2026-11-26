using System;
using System.IO;
using System.Reflection;

// Minimal Unity API for running the original GameSynth music callback offline.
// GameSynth.cs is read from the game repository; it is never modified or copied here.
namespace UnityEngine
{
    public class RequireComponent : Attribute { public RequireComponent(Type type) { } }
    public class MonoBehaviour { public T GetComponent<T>() where T : new() => new T(); }
    public class AudioSource
    {
        public bool playOnAwake, loop;
        public float spatialBlend;
        public void Play() { }
    }
    public static class AudioSettings { public static int outputSampleRate = 22050; }
    public static class Mathf
    {
        public const float PI = (float)Math.PI;
        public static float Clamp01(float value) => Math.Clamp(value, 0f, 1f);
        public static float Max(float a, float b) => Math.Max(a, b);
        public static float Pow(float a, float b) => MathF.Pow(a, b);
        public static float Exp(float value) => MathF.Exp(value);
    }
}

// The export has no roulette/SFX; only GameSynth's original music is mixed.
namespace FatFish.Roulette
{
    public class RouletteSound
    {
        public RouletteSound(double sampleRate) { }
        public float Next() => 0f;
    }
}

public static class RenderGameSynth
{
    const BindingFlags Private = BindingFlags.Instance | BindingFlags.NonPublic;
    const int Rate = 22050;
    const int Seed = 184;

    static void Set(GameSynth synth, string name, object value) =>
        typeof(GameSynth).GetField(name, Private).SetValue(synth, value);

    static void StartPhrase(GameSynth synth)
    {
        Set(synth, "random", new Random(Seed));
        Set(synth, "noiseState", 0x9E3779B9u);
        Set(synth, "step", 0);
        Set(synth, "stepTimer", 0.0);
    }

    public static void Main(string[] args)
    {
        var synth = new GameSynth();
        typeof(GameSynth).GetMethod("Awake", Private).Invoke(synth, null);
        synth.SetVolumes(1f, 0f, false);
        synth.Tension = 0f;
        synth.BossMode = false;
        synth.Duck = 1f;
        var render = (Action<float[], int>)Delegate.CreateDelegate(
            typeof(Action<float[], int>), synth,
            typeof(GameSynth).GetMethod("OnAudioFilterRead", Private));

        // Four 4-bar progressions at 86 BPM. Warm up the same phrase first so
        // volume smoothing and the previous E7/vibraphone tails are already present.
        var constants = BindingFlags.Static | BindingFlags.NonPublic;
        double bpm = (double)typeof(GameSynth).GetField("CalmBpm", constants).GetRawConstantValue();
        int bars = (int)typeof(GameSynth).GetField("Bars", constants).GetRawConstantValue();
        int steps = (int)typeof(GameSynth).GetField("StepsPerBar", constants).GetRawConstantValue();
        int frames = (int)Math.Round(Rate * (60.0 / bpm) * bars * steps / 2 * 4);
        var buffer = new float[frames];
        StartPhrase(synth);
        render(buffer, 1);
        StartPhrase(synth);
        render(buffer, 1);
        using var output = new BinaryWriter(File.Create(args[0]));
        foreach (float sample in buffer)
        {
            if (!float.IsFinite(sample)) throw new InvalidDataException("Non-finite audio sample");
            output.Write(sample);
        }
        Console.WriteLine($"GameSynth: {frames} frames, {bpm} BPM, tension=0, seed={Seed}");
    }
}
