using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StartGame : MonoBehaviour
{
    public PlayerSpawner playerSpawner;
    public GameObject StartGameUI;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    public void StartTheGame()
    {
        playerSpawner.SpawnPlayer();
        StartGameUI.SetActive(false);
    }
}
