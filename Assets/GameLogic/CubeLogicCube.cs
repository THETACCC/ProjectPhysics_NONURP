using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CubeLogicCube : MonoBehaviour
{
    public Rigidbody rb;
    public float pushMagnitude = 1250f;

    public float checkRadius = 5f;

    public LayerMask CubeLayer;
    private void Update()
    {
        CheckForCube();
    }

    private void CheckForCube()
    {
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, checkRadius, CubeLayer);
        foreach (var hitCollider in hitColliders)
        {
            if (hitCollider.gameObject.tag == "Cube")
            {
                Debug.Log("Block detected within radius");
                // Calculate the direction from the cube to this object
                Vector3 directionFromCube = transform.position - hitCollider.transform.position;
                directionFromCube.Normalize();

                rb.AddForce(directionFromCube * pushMagnitude);

                break;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("EnterTrigger");
        if (other.gameObject.tag == "GravityBullet" || other.gameObject.tag == "KineticBullet" || other.gameObject.tag == "LiftBullet")
        {
            Destroy(other.gameObject);
            Debug.Log("Bullet destroyed");
        }
    }
}
