using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using HFUtils;

public class Win : MonoBehaviour
{
    public void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            Debug.Log("wins");
            HFUtils.HFUtils.instance.LoadNextScene();
        }
    }
}
