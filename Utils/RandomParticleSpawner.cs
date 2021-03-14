using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace UnityCommon
{
    public class RandomParticleSpawner : MonoBehaviour
    {
        public float SpawnTimeMin = 3;
        public float SpawnTimeMax = 6;

        public GameObject ParticlePrefab;

        private float _time;

        // Start is called before the first frame update
        private void Start()
        {
            _time = Random.Range(SpawnTimeMin, SpawnTimeMax);
        }

        private Vector3 GetPoint(Collider c, Vector3 input)
        {
            if (c is MeshCollider mc && !mc.convex) { return default; }
            return c.ClosestPoint(input);
        }

        // Update is called once per frame
        private void Update()
        {
            if (_time > 0)
            {
                _time -= Time.deltaTime;
                if (_time < 0) { _time = 0; }
            }

            if (_time <= 0)
            {
                var pfx = Instantiate(ParticlePrefab);
                pfx.transform.position = this.transform.position;
                _time = Random.Range(SpawnTimeMin, SpawnTimeMax);
            }
        }
    }
}