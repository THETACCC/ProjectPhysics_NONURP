using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class GunChangeMode : MonoBehaviour
{

    public Material[] materials;
    public GameObject modePart1;
    public GameObject modePart2;
    public GameObject modePart3;
    public int mode;
    Renderer[] renders;
    // Start is called before the first frame update
    void Start()
    {
        mode = 0;
        renders = new Renderer[3];
        renders[0] = modePart1.GetComponent<Renderer>();
        renders[1] = modePart2.GetComponent<Renderer>();
        renders[2] = modePart3.GetComponent<Renderer>();
        Array.ForEach(renders, renderer => renderer.enabled = true);
    }
    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(1))
        {
            if (renders.All(renderer => renderer.sharedMaterial == materials[0]))
            {
                Array.ForEach(renders, renderer => renderer.sharedMaterial = materials[1]);
                mode =  1;
            }
            else if (renders.All(renderer => renderer.sharedMaterial == materials[1]))
            {
                mode = 2;
                Array.ForEach(renders, renderer => renderer.sharedMaterial = materials[2]);
            }
            else if (renders.All(renderer => renderer.sharedMaterial == materials[2]))
            {
                mode = 0;
                Array.ForEach(renders, renderer => renderer.sharedMaterial = materials[0]);
            }

        }
    }
}
