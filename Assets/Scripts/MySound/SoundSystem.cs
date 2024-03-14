using UnityEngine.Audio;
using UnityEngine;
using System;
using System.Collections.Generic;
using Random = UnityEngine.Random;
using System.Collections;

public class SoundSystem : MonoBehaviour
{

    public Sound[] sounds;
    public Sound[] music;
    public static SoundSystem instance;
    public AudioSource musicSource;
    public AudioSource lastPlayedSFX;
    public List<AudioSource> soundEffectsSources;
    public bool mutesounds = false;

    // Start is called before the first frame update

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else {
            Destroy(gameObject);
            return;
        }
        DontDestroyOnLoad(gameObject);

        foreach (Sound s in sounds)
        {
            s.source = gameObject.AddComponent<AudioSource>();
            s.source.clip = s.clip;

            s.source.volume = s.volume;
            s.source.pitch = s.pitch;
            s.source.loop = s.loop;

            soundEffectsSources.Add(s.source);

        }

        musicSource = gameObject.AddComponent<AudioSource>();

    }

    public void Start()
    {

    }

    public void PlaySound(string name)
    {



        Sound s = Array.Find(sounds, sound => sound.name == name);

        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found");
            return;
        }
        else 
        {

           Debug.Log("play sound: " + s.name);

        }


        lastPlayedSFX = s.source;

        s.source.Play();

    }

    public void StopLastSound() 
    {
        if (lastPlayedSFX)
        {
            lastPlayedSFX.Stop();
        }
    }

    public void PlayMusic(string name)
    {
        musicSource.Stop();
        Sound s = Array.Find(music, sound => sound.name == name);

        if (s == null)
        {
            Debug.LogWarning("Sound: " + name + " not found");
            return;
        }
        Debug.Log("PlaySounds"); 
        musicSource.clip = s.clip;        
        musicSource.volume = s.volume;
        musicSource.pitch = s.pitch;
        musicSource.loop = s.loop;

        musicSource.Play();

    }

    public void StopMusic() 
    {
        musicSource.Stop();

    }






    public void StopAllSounds() 
    {

        foreach (AudioSource s in soundEffectsSources) { s.Stop(); }

    }
}
