using UnityEngine;

/// <summary>Central audio routing for ambience, effects and music.</summary>
public sealed class RunnerAudioManager : MonoBehaviour
{
    [Header("Sources")]
    [SerializeField] private AudioSource ambienceSource;
    [SerializeField] private AudioSource effectsSource;
    [SerializeField] private AudioSource musicSource;

    [Header("Volume")]
    [Range(0f, 1f)] [SerializeField] private float masterVolume = 1f;
    [Range(0f, 1f)] [SerializeField] private float ambienceVolume = 0.8f;
    [Range(0f, 1f)] [SerializeField] private float effectsVolume = 1f;
    [Range(0f, 1f)] [SerializeField] private float musicVolume = 0.55f;

    private void Start() => ApplyVolumes();

    public void PlayEffect(AudioClip clip)
    {
        if (clip != null && effectsSource != null)
            effectsSource.PlayOneShot(clip, masterVolume * effectsVolume);
    }

    public void SetAmbience(AudioClip clip)
    {
        if (ambienceSource == null || clip == null) return;
        if (ambienceSource.clip == clip && ambienceSource.isPlaying) return;
        ambienceSource.clip = clip;
        ambienceSource.loop = true;
        ambienceSource.Play();
    }

    public void SetMusic(AudioClip clip)
    {
        if (musicSource == null || clip == null) return;
        if (musicSource.clip == clip && musicSource.isPlaying) return;
        musicSource.clip = clip;
        musicSource.loop = true;
        musicSource.Play();
    }

    public void SetMasterVolume(float value) { masterVolume = Mathf.Clamp01(value); ApplyVolumes(); }
    public void SetAmbienceVolume(float value) { ambienceVolume = Mathf.Clamp01(value); ApplyVolumes(); }
    public void SetEffectsVolume(float value) { effectsVolume = Mathf.Clamp01(value); ApplyVolumes(); }
    public void SetMusicVolume(float value) { musicVolume = Mathf.Clamp01(value); ApplyVolumes(); }

    private void ApplyVolumes()
    {
        if (ambienceSource != null) ambienceSource.volume = masterVolume * ambienceVolume;
        if (effectsSource != null) effectsSource.volume = masterVolume * effectsVolume;
        if (musicSource != null) musicSource.volume = masterVolume * musicVolume;
    }
}
