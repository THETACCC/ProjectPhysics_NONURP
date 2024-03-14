using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterCollision : MonoBehaviour
{
    public Transform prototypeCheckpoint;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            // Check if the game object has a parent
            if (other.gameObject.transform.parent != null)
            {
                other.gameObject.transform.parent.position = prototypeCheckpoint.position;
            }
            else
            {
                Debug.Log("The object does not have a parent.");
            }
        }
    }
}
