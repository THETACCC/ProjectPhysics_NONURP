using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeleportPlayer : MonoBehaviour
{

    public Transform teleportPoint;

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("SomeoneEnter");

        if (other.gameObject.tag == "Player")
        {
            //other.gameObject.transform.position = teleportPoint.position;
            other.transform.parent.position = teleportPoint.position;

        }
    }
}
