using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityCommon
{
    [DefaultExecutionOrder(-29000)]
    public class BgRunner : MonoBehaviour
    {
        public static BgRunner Instance { get; private set; }

        public void Awake()
        {
            if (Instance && Instance != this)
            {
                // Potential Bug #5: This is a bug because destroying the entire duplicate GameObject also destroys unrelated sibling components and does so immediately while Awake callbacks may still be running.
                // Suggested Fix: Use Destroy(this) to remove only the duplicate BgRunner component at the end of the frame.
                // Related: #16, #17.
                DestroyImmediate(this.gameObject);
            }
            else
            {
                Instance = this;
                DontDestroyOnLoad(this);
            }
        }

        public static Coroutine TryRunCoRoutine(IEnumerator coroutine)
        {
            if (!Instance)
            {
                Utils.EnsureBgRunner();
            }

            if (coroutine != null && Instance && Instance.isActiveAndEnabled)
            {
                return Instance.StartCoroutine(coroutine);
            }

            return null;
        }
    }
}