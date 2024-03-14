using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Unity.VisualScripting.Member;

public class Bullet : MonoBehaviour
{



    public Vector3 bulletSpeed;
    public float bulletLifetime;
    private bool _isGhost;
    public void DestroyWhenTooLong()
    {
        Destroy(gameObject);
    }

    public void Update()
    {

    }

    public void Init(Vector3 velocity, bool isGhost)
    {
        _isGhost = isGhost;
        GetComponent<Rigidbody>().AddForce(velocity, ForceMode.Impulse);
    }
    public virtual void OnCollisionEnter(Collision col)
    {
        if (_isGhost) return;
    }


}
