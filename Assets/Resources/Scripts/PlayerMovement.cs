using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    // Start is called before the first frame update
    Rigidbody2D rb;
    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
    }

    bool onGround()
    {
        var start = transform.position + Vector3.down * 0.55f + Vector3.left * 0.5f;
        Debug.DrawLine(start, start + Vector3.right, Color.red);
        return Physics2D.Raycast(transform.position + Vector3.down * 0.55f + Vector3.left * 0.5f, Vector3.right, 1f);
    }

    // Update is called once per frame
    void Update()
    {
        bool pressJump = Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.UpArrow);
        bool isOnGround = onGround();
        if (pressJump && isOnGround)
        {
            rb.AddForce(Vector2.up * 300f);
        }
        rb.velocity = new Vector2(Input.GetAxis("Horizontal") * 5, rb.velocity.y);

    }
}
