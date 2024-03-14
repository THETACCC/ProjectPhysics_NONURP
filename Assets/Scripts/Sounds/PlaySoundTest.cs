using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaySoundTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        SoundSystem.instance.PlayMusic("MyBGM");
    }

    // Update is called once per frame
    void Update()
    {

    }
}
