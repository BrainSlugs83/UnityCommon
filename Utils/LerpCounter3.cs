using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace UnityCommon
{
    public class LerpCounter3
    {
        public Vector3 Start { get; set; }

        private Vector3 _stop;

        public Vector3 Stop
        {
            get { return _stop; }
            set
            {
                if (_stop != value)
                {
                    Start = Current;
                    _stop = value;
                    Counter = 0;
                }
            }
        }

        public float Counter { get; private set; }

        public Func<float, float> EasingFunc { get; set; } = EasingUtils.LinearInterpolation;

        public Vector3 Current => Vector3.Lerp(Start, Stop, EasingFunc(Counter));

        public void Count(float amount)
        {
            Counter = Mathf.Clamp01(Counter + amount);
        }
    }
}