using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace UnityCommon
{
    public enum CurveType
    {
        Linear = 0,
        Quadratic = 3,
        Cubic = 6,
        Quartic = 9,
        Quintic = 12,
        Sine = 15,
        Circular = 18,
        Exponential = 21,
        Elastic = 24,
        Back = 27,
        Bounce = 30
    };

    public enum EasingMode
    {
        In = 0,
        Out = 1,
        InOut = 2,
    };

    public static class EasingUtils
    {
        private const float HalfOfPi = Mathf.PI / 2f;

        public static float Lerp(float a, float b, float p) => a + ((b - a) * p);

        public static float UnLerp(float a, float b, float value) => (value - a) / (b - a);

        public static float Clamp(float min, float max, float value)
        {
            if (value < min) { return min; }
            else if (value > max) { return max; }
            else { return value; }
        }

        public static float LinearInterpolation(float p) => Clamp(0f, 1f, p);

        private static readonly Func<float, float>[] funcTable = new Func<float, float>[]
        {
            LinearInterpolation, LinearInterpolation, LinearInterpolation,
            QuadraticEaseIn, QuadraticEaseOut, QuadraticEaseInOut,
            CubicEaseIn, CubicEaseOut, CubicEaseInOut,
            QuarticEaseIn, QuarticEaseOut, QuarticEaseInOut,
            QuinticEaseIn, QuinticEaseOut, QuinticEaseInOut,
            SineEaseIn, SineEaseOut, SineEaseInOut,
            CircularEaseIn, CircularEaseOut, CircularEaseInOut,
            ExponentialEaseIn, ExponentialEaseOut, ExponentialEaseInOut,
            ElasticEaseIn, ElasticEaseOut, ElasticEaseInOut,
            BackEaseIn, BackEaseOut, BackEaseInOut,
            BounceEaseIn, BounceEaseOut, BounceEaseInOut
        };

        public static Func<float, float> GetEasingFunc(CurveType curveType, EasingMode easingMode)
        {
            return funcTable[(int)(curveType) + (int)(easingMode)];
        }

        public static float NonLinearInterpolation(float p, CurveType curveType, EasingMode easingMode)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return GetEasingFunc(curveType, easingMode)(p);
        }

        /// <summary>
        /// Modeled after the parabola: y = x ^ 2;
        /// </summary>
        public static float QuadraticEaseIn(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return p * p;
        }

        /// <summary>
        /// Modeled after the parabola: y = -x ^ 2 + 2x;
        /// </summary>
        public static float QuadraticEaseOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return -(p * (p - 2f));
        }

        /// <summary>
        /// <para>Modeled after the piecewise quadratic:</para>
        /// <para>y = (1/2) ((2x) ^ 2); [0, 0.5)</para>
        /// <para>y = -(1/2) ((2x - 1) * (2x - 3) - 1); [0.5, 1]</para>
        /// </summary>
        public static float QuadraticEaseInOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }

            if (p < 0.5f)
            {
                return 2f * p * p;
            }
            else
            {
                return (-2f * p * p) + (4f * p) - 1f;
            }
        }

        /// <summary>
        /// Modeled after the cubic: y = x ^ 3;
        /// </summary>
        public static float CubicEaseIn(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return p * p * p;
        }

        /// <summary>
        /// Modeled after the cubic: y = (x - 1) ^ 3 + 1;
        /// </summary>
        public static float CubicEaseOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            float f = (p - 1f);
            return f * f * f + 1f;
        }

        /// <summary>
        /// <para>Modeled after the piecewise cubic:</para>
        /// <para>y = (1/2) ((2x) ^ 3) ; [0, 0.5)</para>
        /// <para>y = (1/2) ((2x - 2) ^ 3 + 2) ; [0.5, 1]</para>
        /// </summary>
        public static float CubicEaseInOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            if (p < 0.5f)
            {
                return 4f * p * p * p;
            }
            else
            {
                float f = ((2f * p) - 2f);
                return 0.5f * f * f * f + 1f;
            }
        }

        /// <summary>
        /// Modeled after the quartic: x ^ 4;
        /// </summary>
        public static float QuarticEaseIn(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return p * p * p * p;
        }

        /// <summary>
        /// Modeled after the quartic: y = 1f - (x - 1) ^ 4;
        /// </summary>
        public static float QuarticEaseOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            float f = (p - 1f);
            return f * f * f * (1f - p) + 1f;
        }

        /// <summary>
        /// <para>Modeled after the piecewise quartic:</para>
        /// <para>y = (1/2) ((2x) ^ 4); [0, 0.5)</para>
        /// <para>y = -(1/2) ((2x - 2) ^ 4 - 2); [0.5, 1]</para>
        /// </summary>
        public static float QuarticEaseInOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            if (p < 0.5f)
            {
                return 8f * p * p * p * p;
            }
            else
            {
                float f = (p - 1f);
                return -8f * f * f * f * f + 1f;
            }
        }

        /// <summary>
        /// Modeled after the quintic: y = x ^ 5;
        /// </summary>
        public static float QuinticEaseIn(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return p * p * p * p * p;
        }

        /// <summary>
        /// Modeled after the quintic: y = (x - 1) ^ 5 + 1;
        /// </summary>
        public static float QuinticEaseOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            float f = (p - 1f);
            return f * f * f * f * f + 1f;
        }

        /// <summary>
        /// <para>Modeled after the piecewise quintic:</para>
        /// <para>y = (1/2) ((2x) ^ 5); [0, 0.5)</para>
        /// <para>y = (1/2) ((2x-2) ^ 5 + 2); [0.5, 1]</para>
        /// </summary>
        public static float QuinticEaseInOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            if (p < 0.5f)
            {
                return 16f * p * p * p * p * p;
            }
            else
            {
                float f = ((2f * p) - 2f);
                return 0.5f * f * f * f * f * f + 1f;
            }
        }

        /// <summary>
        /// Modeled after quarter-cycle of Sine wave.
        /// </summary>
        public static float SineEaseIn(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return Mathf.Sin((p - 1f) * HalfOfPi) + 1f;
        }

        /// <summary>
        /// Modeled after quarter-cycle of Sine wave (different phase).
        /// </summary>
        public static float SineEaseOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return Mathf.Sin(p * HalfOfPi);
        }

        /// <summary>
        /// Modeled after half Sine wave.
        /// </summary>
        public static float SineEaseInOut(float p)
        {
            if (p <= 0f) { return 0f; } else if (p >= 1f) { return 1f; }
            return 0.5f * (1f - Mathf.Cos(p * Mathf.PI));
        }

        /// <summary>
        /// Modeled after shifted quadrant IV of unit circle.
        /// </summary>
        public static float CircularEaseIn(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }
            else { return 1f - Mathf.Sqrt(1f - (p * p)); }
        }

        /// <summary>
        /// Modeled after shifted quadrant II of unit circle.
        /// </summary>
        public static float CircularEaseOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }
            else { return Mathf.Sqrt((2f - p) * p); }
        }

        /// <summary>
        /// <para>Modeled after the piecewise circular function:</para>
        /// <para>y = (1/2) (1 - Mathf.Sqrt(1 - 4x ^ 2)); [0, 0.5)</para>
        /// <para>y = (1/2) (Mathf.Sqrt(-(2x - 3) * (2x - 1)) + 1); [0.5, 1]</para>
        /// </summary>
        public static float CircularEaseInOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }
            else if (p < 0.5f)
            {
                return 0.5f * (1f - Mathf.Sqrt(1f - 4f * (p * p)));
            }
            else
            {
                return 0.5f * (Mathf.Sqrt(-((2f * p) - 3f) * ((2f * p) - 1f)) + 1f);
            }
        }

        /// <summary>
        /// Modeled after the exponential function: y = 2 ^ (10 (x - 1))
        /// </summary>
        public static float ExponentialEaseIn(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            return Mathf.Pow(2f, 10f * (p - 1f));
        }

        /// <summary>
        /// Modeled after the exponential function y = -2 ^ (-10x) + 1
        /// </summary>
        public static float ExponentialEaseOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            return (p == 1.0f) ? p : 1f - Mathf.Pow(2f, -10f * p);
        }

        /// <summary>
        /// <para>Modeled after the piecewise exponential:</para>
        /// <para>y = (1/2) 2 ^ (10 (2x - 1)); [0,0.5)</para>
        /// <para>y = -(1/2) * 2 ^ (-10 (2x - 1))) + 1; [0.5,1]</para>
        /// </summary>
        public static float ExponentialEaseInOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            if (p < 0.5f)
            {
                return 0.5f * Mathf.Pow(2f, (20f * p) - 10f);
            }
            else
            {
                return -0.5f * Mathf.Pow(2f, (-20f * p) + 10f) + 1f;
            }
        }

        /// <summary>
        /// <para>Modeled after the damped Sine wave:</para>
        /// <para>y = Mathf.Sin(13 pi / 2 * x) * Mathf.Pow(2, 10 * (x - 1));</para>
        /// </summary>
        public static float ElasticEaseIn(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            return Mathf.Sin(13f * HalfOfPi * p) * Mathf.Pow(2f, 10f * (p - 1f));
        }

        /// <summary>
        /// <para>Modeled after the damped Sine wave:</para>
        /// <para>y = Mathf.Sin(-13 pi / 2 * (x + 1)) * Mathf.Pow(2, -10x) + 1</para>
        /// </summary>
        public static float ElasticEaseOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            return Mathf.Sin(-13f * HalfOfPi * (p + 1f)) * Mathf.Pow(2f, -10f * p) + 1f;
        }

        /// <summary>
        /// <para>Modeled after the piecewise exponentially-damped Sine wave:</para>
        /// <para>
        /// y = (1/2) * Mathf.Sin(13 pi / 2 * (2 * x)) * Mathf.Pow(2, 10 * ((2 * x) - 1)); [0,0.5)
        /// </para>
        /// <para>
        /// y = (1/2) * (Mathf.Sin(-13 pi / 2 * ((2x - 1) + 1)) * Mathf.Pow(2, -10(2 * x - 1)) + 2);
        /// [0.5, 1]
        /// </para>
        /// </summary>
        public static float ElasticEaseInOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            if (p < 0.5f)
            {
                return 0.5f * Mathf.Sin(13f * HalfOfPi * (2f * p)) * Mathf.Pow(2f, 10f * ((2f * p) - 1f));
            }
            else
            {
                return 0.5f * (Mathf.Sin(-13f * HalfOfPi * ((2f * p - 1f) + 1f)) * Mathf.Pow(2f, -10f * (2f * p - 1f)) + 2f);
            }
        }

        /// <summary>
        /// Modeled after the overshooting cubic: y = x ^ 3 - x * Mathf.Sin(x * pi);
        /// </summary>
        public static float BackEaseIn(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            return p * p * p - p * Mathf.Sin(p * Mathf.PI);
        }

        /// <summary>
        /// Modeled after overshooting cubic: y = 1 - ((1 - x) ^ 3 - (1 - x) * Mathf.Sin((1 - x) * pi));
        /// </summary>
        public static float BackEaseOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            float f = (1f - p);
            return 1f - (f * f * f - f * Mathf.Sin(f * Mathf.PI));
        }

        /// <summary>
        /// <para>Modeled after the piecewise overshooting cubic function:</para>
        /// <para>y = (1/2) * ((2x) ^ 3 - (2x) * Mathf.Sin(2 * x * pi)); [0, 0.5)</para>
        /// <para>y = (1/2) * (1-((1-x) ^ 3 - (1-x) * Mathf.Sin((1 - x) * pi)) + 1); [0.5, 1]</para>
        /// </summary>
        public static float BackEaseInOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            if (p < 0.5f)
            {
                float f = 2f * p;
                return 0.5f * (f * f * f - f * Mathf.Sin(f * Mathf.PI));
            }
            else
            {
                float f = (1f - (2f * p - 1f));
                return 0.5f * (1f - (f * f * f - f * Mathf.Sin(f * Mathf.PI))) + 0.5f;
            }
        }

        public static float BounceEaseIn(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            return 1f - BounceEaseOut(1f - p);
        }

        public static float BounceEaseOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            if (p < (4f / 11f))
            {
                return (121f * p * p) / 16.0f;
            }
            else if (p < (8f / 11.0f))
            {
                return (363f / 40.0f * p * p) - (99f / 10.0f * p) + 17f / 5.0f;
            }
            else if (p < 9f / 10.0f)
            {
                return (4356f / 361.0f * p * p) - (35442f / 1805.0f * p) + 16061f / 1805.0f;
            }
            else
            {
                return (54f / 5.0f * p * p) - (513f / 25.0f * p) + 268f / 25.0f;
            }
        }

        public static float BounceEaseInOut(float p)
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            if (p < 0.5f)
            {
                return 0.5f * BounceEaseIn(p * 2f);
            }
            else
            {
                return 0.5f * BounceEaseOut(p * 2f - 1f) + 0.5f;
            }
        }

        /// <summary>
        /// Performs Hermite Interpolation.
        /// </summary>
        /// <param name="y0">The value preceeding min.</param>
        /// <param name="y1">The min value.</param>
        /// <param name="y2">The max value.</param>
        /// <param name="y3">The value following max.</param>
        /// <param name="p">The percent of the transition between min and max.</param>
        /// <param name="tension">The tension (-1 is low, 0 is normal, and 1 is high).</param>
        /// <param name="bias">
        /// The bias (0 is even, positive is towards the first segment, negative is towards the other).
        /// </param>
        public static float Herp
        (
           float y0, float y1,
           float y2, float y3,
           float p,
           float tension,
           float bias
        )
        {
            if (p <= 0.0f) { return 0.0f; }
            else if (p >= 1.0f) { return 1.0f; }

            float m0, m1, mu2, mu3;
            float a0, a1, a2, a3;

            mu2 = p * p;
            mu3 = mu2 * p;
            m0 = (y1 - y0) * (1 + bias) * (1 - tension) / 2;
            m0 += (y2 - y1) * (1 - bias) * (1 - tension) / 2;
            m1 = (y2 - y1) * (1 + bias) * (1 - tension) / 2;
            m1 += (y3 - y2) * (1 - bias) * (1 - tension) / 2;
            a0 = 2 * mu3 - 3 * mu2 + 1;
            a1 = mu3 - 2 * mu2 + p;
            a2 = mu3 - mu2;
            a3 = -2 * mu3 + 3 * mu2;

            return (a0 * y1 + a1 * m0 + a2 * m1 + a3 * y2);
        }
    }

    public class CompoundEasingFuncBuilder
    {
        private struct EasingFuncEntry
        {
            public float Weight;
            public Func<float, float> Func;
        }

        private List<EasingFuncEntry> Entries = new List<EasingFuncEntry>();

        public CompoundEasingFuncBuilder WithFunc(Func<float, float> func, float weight)
        {
            if (func != null && weight > 0f)
            {
                Entries.Add(new EasingFuncEntry { Weight = weight, Func = func });
            }
            return this;
        }

        public CompoundEasingFuncBuilder WithFunc(CurveType curveType, EasingMode easingMode, float weight)
        {
            return WithFunc(EasingUtils.GetEasingFunc(curveType, easingMode), weight);
        }

        public Func<float, float> Build()
        {
            if (Entries.Count < 1) { return EasingUtils.LinearInterpolation; }

            var e = Entries.ToArray();

            // normalize the weights between 0 and 1.
            float total = e.Select(x => x.Weight).Sum();

            var mins = new float[e.Length]; // inclusive min for a given range
            var maxs = new float[e.Length]; // exclusive max for a given range

            float l = 0f;
            for (int i = 0; i < e.Length; i++)
            {
                e[i].Weight /= total;

                mins[i] = l;
                l += e[i].Weight;
                maxs[i] = l;
            }

            return p =>
            {
                if (p <= 0f) { return 0f; }
                else if (p >= 1f) { return 1f; }

                for (int i = 0; i < e.Length; i++)
                {
                    if (p >= mins[i] && p < maxs[i])
                    {
                        var v = EasingUtils.UnLerp(mins[i], maxs[i], p);
                        return mins[i] + (e[i].Func(v) * e[i].Weight);
                    }
                }

                return p; // regular lerp
            };
        }
    }
}