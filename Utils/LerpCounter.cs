using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace UnityCommon
{
    public class LerpCounter
    {
        public float Start { get; set; }

        private float _stop;

        public float Stop
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

        public float Current => Mathf.Lerp(Start, Stop, EasingFunc(Counter));

        public void Count(float amount)
        {
            Counter = Mathf.Clamp01(Counter + amount);
        }
    }
}