using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityCommon
{
    public class ParticleSystemAutoCleanup : MonoBehaviour
    {
        private ParticleSystem[] syss;

        // Start is called before the first frame update
        private void Start()
        {
            syss = GetComponentsInChildren<ParticleSystem>();
            if (syss == null || syss.Length == 0)
            {
                DestroyImmediate(this);
                return;
            }
        }

        // Update is called once per frame
        private void FixedUpdate()
        {
            if (syss != null)
            {
                foreach (var sys in syss)
                {
                    if (sys && sys.IsAlive(true)) { return; }
                }

                syss = null;
            }

            DestroyImmediate(this.gameObject);
        }
    }
}