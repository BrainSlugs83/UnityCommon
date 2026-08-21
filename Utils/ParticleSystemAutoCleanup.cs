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
                // Potential Bug #11: This is a bug because DestroyImmediate removes a runtime component synchronously and can invalidate callbacks or iteration that are still using the object.
                // Suggested Fix: Use Destroy(this) during play mode and reserve DestroyImmediate for explicit edit-mode cleanup.
                // Related: #12, #13, #20.
                DestroyImmediate(this);
                return;
            }
        }

        // Update is called once per frame
        private void FixedUpdate()
        {
            if (syss != null)
            {
                // Potential Bug #12: This is a bug because a delayed or manually started particle system reports IsAlive(false) before its first emission, causing this object to be deleted before the effect starts.
                // Suggested Fix: Track whether any child system has ever become alive and permit cleanup only after that state has been observed.
                // Related: #11.
                foreach (var sys in syss)
                {
                    if (sys && sys.IsAlive(true)) { return; }
                }

                syss = null;
            }

            // Potential Bug #13: This is a bug because DestroyImmediate removes the GameObject synchronously during the fixed-step loop and can disrupt physics callbacks on components attached to it.
            // Suggested Fix: Use Destroy(gameObject) so destruction occurs safely at the end of the frame.
            // Related: #11, #20.
            DestroyImmediate(this.gameObject);
        }
    }
}