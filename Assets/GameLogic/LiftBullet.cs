using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LiftBullet : Bullet
{
    private void Start()
    {
        Invoke("DestroyWhenTooLong", bulletLifetime);
    }




    public override void OnCollisionEnter(Collision collision)
    {
        base.OnCollisionEnter(collision);
        if (collision.gameObject.tag == "Interactions")
        {
            //Rigidbody colRigidbody = collision.gameObject.GetComponent<Rigidbody>();
            //colRigidbody.AddForce(-transform.forward * 100);
            Destroy(gameObject);
        }
    }
}
