using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DespawnOnHeight : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        // Go to game over scene when the player falls below the map
        if (transform.position.y < -1)
        {
            SceneManager.LoadScene("GameOver");
            /* TODO: Stop whispers */
        }
    }
}
