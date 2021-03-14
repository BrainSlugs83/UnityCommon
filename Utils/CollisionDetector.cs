using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

#if UNITY_EDITOR

using System.Diagnostics;

#endif

namespace UnityCommon
{
    public class CollisionDetector : MonoBehaviour
    {
#if UNITY_EDITOR

        public int ColliderCount;
        public bool AmDebugging = false;

#endif

        public IEnumerable<GameObject> CollidingWith => CollidingAt.Keys.Where(x => x != null);
        public Dictionary<GameObject, Vector3[]> CollidingAt { get; } = new Dictionary<GameObject, Vector3[]>();

        private Dictionary<GameObject, HashSet<Collider>> colliders = new Dictionary<GameObject, HashSet<Collider>>();

        private void Awake()
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif

            CollidingAt.Clear();
        }

        private void Start()
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif
            CollidingAt.Clear();
        }

        private void OnDisable()
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif
            CollidingAt.Clear();
        }

        private void OnEnable()
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif
            CollidingAt.Clear();
        }

        public void AddCollider(GameObject go, Collider co)
        {
            if (!CollidingAt.ContainsKey(go) || !colliders.ContainsKey(go))
            {
                colliders[go] = new HashSet<Collider>();
            }

            colliders[go].Add(co);
        }

        public void RemoveCollider(GameObject go, Collider co)
        {
            if (colliders.ContainsKey(go))
            {
                colliders[go].Remove(co);
                if (colliders[go].Count < 1)
                {
                    colliders.Remove(go);
                }
            }
        }

        private void OnCollisionEnter(Collision collision)
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif

            AddCollider(collision.gameObject, collision.collider);
            CollidingAt[collision.gameObject] = collision.contacts.Select(x => x.point).ToArray();
        }

        private void OnCollisionExit(Collision collision)
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif

            var go = collision.gameObject;
            CollidingAt.Remove(go);
            RemoveCollider(collision.gameObject, collision.collider);
        }

        public void SetObjectCollisionState(GameObject o, bool state)
        {
            if (state)
            {
                var collider = o.GetComponentsInChildren<Collider>()
                    .OrderByDescending(x => (transform.position - x.ClosestPointOnBounds(transform.position)).magnitude)
                    .FirstOrDefault();

                if (collider)
                {
                    OnTriggerEnter(collider);
                }
            }
            else
            {
                foreach (var collider in o.GetComponentsInChildren<Collider>())
                {
                    OnTriggerExit(collider);
                }
            }
        }

        private void OnTriggerEnter(Collider other)
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif
            AddCollider(other.gameObject, other);
            CollidingAt[other.gameObject] = new[] { other.ClosestPointOnBounds(transform.position) };
        }

        private void OnTriggerExit(Collider other)
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif
            var go = other.gameObject;
            CollidingAt.Remove(go);
            RemoveCollider(other.gameObject, other);
        }

        public IEnumerable<Collider> GetCollders(GameObject go)
        {
#if UNITY_EDITOR
            if (AmDebugging && Debugger.IsAttached) { Debugger.Break(); }
#endif
            if (colliders.ContainsKey(go))
            {
                return colliders[go];
            }

            return Enumerable.Empty<Collider>();
        }

#if UNITY_EDITOR

        private void Update()
        {
            ColliderCount = CollidingWith.Count();
        }

#endif
    }
}