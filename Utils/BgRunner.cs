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