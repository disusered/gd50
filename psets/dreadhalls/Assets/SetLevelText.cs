using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetLevelText : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<UnityEngine.UI.Text>().text = "Level " + PlayerLevel.level;
    }

    // Update is called once per frame
    void Update()
    {

    }
}
