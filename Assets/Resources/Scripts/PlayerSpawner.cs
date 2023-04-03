using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerSpawner : MonoBehaviour
{
    public GameObject player;
    // Start is called before the first frame update
    void Start()
    {

    }

    public void SpawnPlayer()
    {
        player.transform.position = new Vector2(0, 0);
    }

    // Update is called once per frame
    void Update()
    {
        if (player.transform.position.y < -10)
        {
            SpawnPlayer();
        }
    }
}
