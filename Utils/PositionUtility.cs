using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class PositionUtility : MonoBehaviour
{
    public string LocalPosTxt = string.Empty;
    public bool read;
    public bool write;
    public bool randomizeRotation;

    private void Start()
    {
        DestroyImmediate(this);
    }

#if UNITY_EDITOR

    private void OnValidate()
    {
        if (randomizeRotation)
        {
            transform.eulerAngles = new Vector3
            (
                Random.Range(-360, 360), 
                Random.Range(-360, 360), 
                Random.Range(-360, 360)
            );

            randomizeRotation = false;
        }

        if (read)
        {
            var v = transform.localPosition;
            LocalPosTxt = v.x.ToString("0.0#######") + ", " + v.y.ToString("0.0#######") + ", " + v.z.ToString("0.0#######");

            read = false;
        }
        else if (write && !string.IsNullOrWhiteSpace(LocalPosTxt))
        {
            var p = LocalPosTxt.Split(',').Select(x => float.Parse(x.Trim())).ToArray();
            transform.localPosition = new Vector3(p[0], p[1], p[2]);

            write = false;
        }
        else
        {
            read = false;
            write = false;
        }
    }

#endif
}