using System;
using System.IO;
using System.Reflection;

// Minimal Unity API for running the original GameSynth audio callback offline.
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

// Roulette is silent during this export; only the chip SFX is captured.
namespace FatFish.Roulette
{
    public class RouletteSound
    {
        public RouletteSound(double sampleRate) { }
        public float Next() => 0f;
    }
}

public static class RenderNavigationChip
{
    const BindingFlags Private = BindingFlags.Instance | BindingFlags.NonPublic;
    public static void Main(string[] args)
    {
        var synth = new GameSynth();
        typeof(GameSynth).GetMethod("Awake", Private).Invoke(synth, null);
        synth.SetVolumes(0f, 1f, false);
        var render = (Action<float[], int>)Delegate.CreateDelegate(
            typeof(Action<float[], int>), synth,
            typeof(GameSynth).GetMethod("OnAudioFilterRead", Private));
        // Let the SFX gain reach its normal level before the event.
        render(new float[22050 / 2], 1);
        typeof(GameSynth).GetField("noiseState", Private).SetValue(synth, 0x9E3779B9u);
        // GameAudio.Chip at its central pitch (1.0), using the original mixer.
        synth.Play(new GameSynth.Note {
            Wave = GameSynth.Wave.Noise, From = 2500f, To = 2500f,
            Duration = 0.035f, Volume = 0.5f,
        });
        synth.Play(new GameSynth.Note {
            Wave = GameSynth.Wave.Triangle, From = 2200f, To = 1700f,
            Duration = 0.03f, Volume = 0.25f,
        });
        var buffer = new float[(int)(22050 * 0.08)];
        render(buffer, 1);
        using var output = new BinaryWriter(File.Create(args[0]));
        foreach (var sample in buffer) {
            if (!float.IsFinite(sample)) throw new InvalidDataException("Non-finite sample");
            output.Write(sample);
        }
    }
}
