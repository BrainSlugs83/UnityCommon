#if UNITY
using UnityEngine;
#else

using System;
using System.Drawing;

#endif

namespace UnityCommon
{
    public struct IntVector2
    {
        public static IntVector2 zero => default;
        public static IntVector2 one => new IntVector2(1, 1);

        public int x;
        public int y;

        public float magnitude => MathF.Sqrt(x * x + y * y);

        public IntVector2(int x, int y)
        {
            this.x = x;
            this.y = y;
        }

        public override string ToString()
        {
            return $"({x}, {y})";
        }

        public override int GetHashCode()
        {
#if UNITY
            return new Vector2(x, y).GetHashCode();
#else
            return new Point(x, y).GetHashCode();
#endif
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(obj, null)) { return false; }
            else if (obj is IntVector2 iv)
            {
                return iv.x == x && iv.y == y;
            }
#if UNITY
            else if (obj is Vector2 v)
            {
                return new Vector2(x, y) == v;
            }
#endif
            else if (obj is System.Numerics.Vector2 nv)
            {
                return new System.Numerics.Vector2(x, y) == nv;
            }
            else if (obj is System.Drawing.Point p)
            {
                return new System.Drawing.Point(x, y) == p;
            }
            else if (obj is System.Drawing.PointF pf)
            {
                return new System.Drawing.PointF(x, y) == pf;
            }
            else
            {
                return false;
            }
        }

        public static bool operator ==(IntVector2 a, object b) => a.Equals(b);

        public static bool operator !=(IntVector2 a, object b) => !a.Equals(b);

        public static implicit operator IntVector2(int i) => zero + i;

#if UNITY
        public static implicit operator Vector2(IntVector2 iv) => new Vector2(iv.x, iv.y);
#endif

        public static implicit operator System.Numerics.Vector2(IntVector2 iv) => new System.Numerics.Vector2(iv.x, iv.y);

        public static implicit operator System.Drawing.Point(IntVector2 iv) => new System.Drawing.Point(iv.x, iv.y);

        public static implicit operator System.Drawing.PointF(IntVector2 iv) => new System.Drawing.PointF(iv.x, iv.y);

        public static implicit operator IntVector2(System.Drawing.Point p) => new IntVector2(p.X, p.Y);

        public static implicit operator IntVector3(IntVector2 v) => new IntVector3(v.x, v.y, 0);

        public static implicit operator IntVector4(IntVector2 v) => new IntVector4(v.x, v.y, 0, 0);

#if UNITY
        public static explicit operator IntVector2(Vector2 v) => new IntVector2((int)v.x, (int)v.y);
#endif

        public static explicit operator IntVector2(System.Numerics.Vector2 v) => new IntVector2((int)v.X, (int)v.Y);

        public static explicit operator IntVector2(System.Drawing.PointF pf) => new IntVector2((int)pf.X, (int)pf.Y);

        public static explicit operator IntVector2(IntVector3 v) => new IntVector2(v.x, v.y);

        public static explicit operator IntVector2(IntVector4 v) => new IntVector2(v.x, v.y);

        // IntVector (op) Int
        public static IntVector2 operator *(IntVector2 a, int b) => new IntVector2(a.x * b, a.y * b);

        public static IntVector2 operator *(int a, IntVector2 b) => new IntVector2(a * b.x, a * b.y);

        public static IntVector2 operator /(IntVector2 a, int b) => new IntVector2(a.x / b, a.y / b);

        public static IntVector2 operator +(IntVector2 a, int b) => new IntVector2(a.x + b, a.y + b);

        public static IntVector2 operator +(int a, IntVector2 b) => new IntVector2(a + b.x, a + b.y);

        public static IntVector2 operator -(IntVector2 a, int b) => new IntVector2(a.x - b, a.y - b);

        public static IntVector2 operator -(int a, IntVector2 b) => new IntVector2(a - b.x, a - b.y);

#if UNITY
        // IntVector (op) Float
        public static Vector2 operator *(IntVector2 a, float b) => ((Vector2)a) * b;

        public static Vector2 operator *(float a, IntVector2 b) => a * ((Vector2)b);

        public static Vector2 operator /(IntVector2 a, float b) => ((Vector2)a) / b;

        public static Vector2 operator +(IntVector2 a, float b) => ((Vector2)a) + new Vector2(b, b);

        public static Vector2 operator +(float a, IntVector2 b) => new Vector2(a, a) + ((Vector2)b);

        public static Vector2 operator -(IntVector2 a, float b) => ((Vector2)a) - new Vector2(b, b);

        public static Vector2 operator -(float a, IntVector2 b) => new Vector2(a, a) - ((Vector2)b);
#endif

        // IntVector (op) IntVector

        public static IntVector2 operator +(IntVector2 a, IntVector2 b) => new IntVector2(a.x + b.x, a.y + b.y);

        public static IntVector2 operator -(IntVector2 a, IntVector2 b) => new IntVector2(a.x - b.x, a.y - b.y);

        public static IntVector2 operator *(IntVector2 left, IntVector2 right) => new IntVector2(left.x * right.x, left.y * right.y);

        public static IntVector2 operator /(IntVector2 left, IntVector2 right) => new IntVector2(left.x / right.x, left.y / right.y);

#if UNITY
        // IntVector (op) Vector
        public static Vector2 operator +(IntVector2 a, Vector2 b) => (Vector2)a + b;

        public static Vector2 operator +(Vector2 a, IntVector2 b) => a + (Vector2)b;

        public static Vector2 operator -(IntVector2 a, Vector2 b) => (Vector2)a - b;

        public static Vector2 operator -(Vector2 a, IntVector2 b) => a - (Vector2)b;

        public static Vector2 operator *(IntVector2 left, Vector2 right) => new Vector2(left.x * right.x, left.y * right.y);

        public static Vector2 operator *(Vector2 left, IntVector2 right) => new Vector2(left.x * right.x, left.y * right.y);

        public static Vector2 operator /(IntVector2 left, Vector2 right) => new Vector2(left.x / right.x, left.y / right.y);

        public static Vector2 operator /(Vector2 left, IntVector2 right) => new Vector2(left.x / right.x, left.y / right.y);
#endif
    }

    public struct IntVector3
    {
        public static IntVector3 zero => default;
        public static IntVector3 one => new IntVector3(1, 1, 1);

        public int x;
        public int y;
        public int z;

        public IntVector3(int x, int y, int z)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public override string ToString()
        {
            return $"({x}, {y}, {z})";
        }

        public override int GetHashCode()
        {
#if UNITY
            return new Vector3(x, y, z).GetHashCode();
#else
            unchecked
            {
                return (x.GetHashCode() ^ 328108021)
                    * (y.GetHashCode() ^ 65906340)
                    + (z.GetHashCode() ^ 1815403660);
            }
#endif
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(obj, null)) { return false; }
            else if (obj is IntVector3 iv)
            {
                return iv.x == x && iv.y == y && iv.z == z;
            }
#if UNITY
            else if (obj is Vector3 v)
            {
                return new Vector3(x, y, z) == v;
            }
#endif
            else if (obj is System.Numerics.Vector3 nv)
            {
                return new System.Numerics.Vector3(x, y, z) == nv;
            }
            else
            {
                return false;
            }
        }

        public static bool operator ==(IntVector3 a, object b) => a.Equals(b);

        public static bool operator !=(IntVector3 a, object b) => !a.Equals(b);

        public static implicit operator IntVector3(int i) => zero + i;

#if UNITY
        public static implicit operator Vector3(IntVector3 iv) => new Vector3(iv.x, iv.y, iv.z);
#endif

        public static implicit operator System.Numerics.Vector3(IntVector3 iv) => new System.Numerics.Vector3(iv.x, iv.y, iv.z);

        public static implicit operator IntVector3(IntVector2 iv) => new IntVector3(iv.x, iv.y, 0);

        public static implicit operator IntVector4(IntVector3 iv) => new IntVector4(iv.x, iv.y, iv.z, 0);

        public static explicit operator IntVector2(IntVector3 iv) => new IntVector2(iv.x, iv.y);

        public static explicit operator IntVector3(IntVector4 iv) => new IntVector3(iv.x, iv.y, iv.z);

#if UNITY
        public static explicit operator IntVector3(Vector3 v) => new IntVector3((int)v.x, (int)v.y, (int)v.z);
#endif

        public static explicit operator IntVector3(System.Numerics.Vector3 v) => new IntVector3((int)v.X, (int)v.Y, (int)v.Z);

        // IntVector (op) Int
        public static IntVector3 operator *(IntVector3 a, int b) => new IntVector3(a.x * b, a.y * b, a.z * b);

        public static IntVector3 operator *(int a, IntVector3 b) => new IntVector3(a * b.x, a * b.y, a * b.z);

        public static IntVector3 operator /(IntVector3 a, int b) => new IntVector3(a.x / b, a.y / b, a.z / b);

        public static IntVector3 operator +(IntVector3 a, int b) => new IntVector3(a.x + b, a.y + b, a.z + b);

        public static IntVector3 operator +(int a, IntVector3 b) => new IntVector3(a + b.x, a + b.y, a + b.z);

        public static IntVector3 operator -(IntVector3 a, int b) => new IntVector3(a.x - b, a.y - b, a.z - b);

        public static IntVector3 operator -(int a, IntVector3 b) => new IntVector3(a - b.x, a - b.y, a - b.z);

#if UNITY
        // IntVector (op) Float

        public static Vector3 operator *(IntVector3 a, float b) => ((Vector3)a) * b;

        public static Vector3 operator *(float a, IntVector3 b) => a * ((Vector3)b);

        public static Vector3 operator /(IntVector3 a, float b) => ((Vector3)a) / b;

        public static Vector3 operator +(IntVector3 a, float b) => ((Vector3)a) + new Vector3(b, b, b);

        public static Vector3 operator +(float a, IntVector3 b) => new Vector3(a, a, a) + ((Vector3)b);

        public static Vector3 operator -(IntVector3 a, float b) => ((Vector3)a) - new Vector3(b, b, b);

        public static Vector3 operator -(float a, IntVector3 b) => new Vector3(a, a, a) - ((Vector3)b);
#endif

        // IntVector (op) IntVector

        public static IntVector3 operator +(IntVector3 a, IntVector3 b) => new IntVector3(a.x + b.x, a.y + b.y, a.z + b.z);

        public static IntVector3 operator -(IntVector3 a, IntVector3 b) => new IntVector3(a.x - b.x, a.y - b.y, a.z - b.z);

        public static IntVector3 operator *(IntVector3 left, IntVector3 right) => new IntVector3(left.x * right.x, left.y * right.y, left.z * right.z);

        public static IntVector3 operator /(IntVector3 left, IntVector3 right) => new IntVector3(left.x / right.x, left.y / right.y, left.z / right.z);

#if UNITY
        // IntVector (op) Vector

        public static Vector3 operator +(IntVector3 a, Vector3 b) => (Vector3)a + b;

        public static Vector3 operator +(Vector3 a, IntVector3 b) => a + (Vector3)b;

        public static Vector3 operator -(IntVector3 a, Vector3 b) => (Vector3)a - b;

        public static Vector3 operator -(Vector3 a, IntVector3 b) => a - (Vector3)b;

        public static Vector3 operator *(IntVector3 left, Vector3 right) => new Vector3(left.x * right.x, left.y * right.y, left.z * right.z);

        public static Vector3 operator *(Vector3 left, IntVector3 right) => new Vector3(left.x * right.x, left.y * right.y, left.z * right.z);

        public static Vector3 operator /(IntVector3 left, Vector3 right) => new Vector3(left.x / right.x, left.y / right.y, left.z / right.z);

        public static Vector3 operator /(Vector3 left, IntVector3 right) => new Vector3(left.x / right.x, left.y / right.y, left.z / right.z);
#endif
    }

    public struct IntVector4
    {
        public static IntVector4 zero => default;
        public static IntVector4 one => new IntVector4(1, 1, 1, 1);

        public int x;
        public int y;
        public int z;
        public int w;

        public IntVector4(int x, int y, int z, int w)
        {
            this.x = x;
            this.y = y;
            this.z = z;
            this.w = w;
        }

        public override string ToString()
        {
            return $"({x}, {y}, {z}, {w})";
        }

        public override int GetHashCode()
        {
#if UNITY
            return new Vector4(x, y, z, w).GetHashCode();
#else
            unchecked
            {
                return
                (
                    (x.GetHashCode() ^ 328108021)
                    * (y.GetHashCode() ^ 65906340)
                    + (z.GetHashCode() ^ 1815403660)
                )
                ^ (w.GetHashCode() ^ 94031232);
            }
#endif
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(obj, null)) { return false; }
            else if (obj is IntVector4 iv)
            {
                return iv.x == x && iv.y == y && iv.z == z && iv.w == w;
            }
#if UNITY
            else if (obj is Vector4 v)
            {
                return new Vector4(x, y, z, w) == v;
            }
#endif
            else if (obj is System.Numerics.Vector4 nv)
            {
                return new System.Numerics.Vector4(x, y, z, w) == nv;
            }
            else
            {
                return false;
            }
        }

        public static bool operator ==(IntVector4 a, object b) => a.Equals(b);

        public static bool operator !=(IntVector4 a, object b) => !a.Equals(b);

        public static implicit operator IntVector4(int i) => zero + i;

#if UNITY
        public static implicit operator Vector4(IntVector4 iv) => new Vector4(iv.x, iv.y, iv.z, iv.w);
#endif

        public static implicit operator System.Numerics.Vector4(IntVector4 iv) => new System.Numerics.Vector4(iv.x, iv.y, iv.z, iv.w);

#if UNITY
        public static explicit operator IntVector4(Vector4 v) => new IntVector4((int)v.x, (int)v.y, (int)v.z, (int)v.w);
#endif

        public static explicit operator IntVector4(System.Numerics.Vector4 v) => new IntVector4((int)v.X, (int)v.Y, (int)v.Z, (int)v.W);

        public static explicit operator IntVector2(IntVector4 v) => new IntVector2(v.x, v.y);

        public static explicit operator IntVector3(IntVector4 v) => new IntVector3(v.x, v.y, v.z);

        public static explicit operator IntVector4(IntVector2 v) => new IntVector4(v.x, v.y, 0, 0);

        public static explicit operator IntVector4(IntVector3 v) => new IntVector4(v.x, v.y, v.z, 0);

        // IntVector (op) Int
        public static IntVector4 operator *(IntVector4 a, int b) => new IntVector4(a.x * b, a.y * b, a.z * b, a.w * b);

        public static IntVector4 operator *(int a, IntVector4 b) => new IntVector4(a * b.x, a * b.y, a * b.z, a * b.w);

        public static IntVector4 operator /(IntVector4 a, int b) => new IntVector4(a.x / b, a.y / b, a.z / b, a.w / b);

        public static IntVector4 operator +(IntVector4 a, int b) => new IntVector4(a.x + b, a.y + b, a.z + b, a.w + b);

        public static IntVector4 operator +(int a, IntVector4 b) => new IntVector4(a + b.x, a + b.y, a + b.z, a + b.w);

        public static IntVector4 operator -(IntVector4 a, int b) => new IntVector4(a.x - b, a.y - b, a.z - b, a.w - b);

        public static IntVector4 operator -(int a, IntVector4 b) => new IntVector4(a - b.x, a - b.y, a - b.z, a - b.w);

#if UNITY
        // IntVector (op) Float
        public static Vector4 operator *(IntVector4 a, float b) => ((Vector4)a) * b;

        public static Vector4 operator *(float a, IntVector4 b) => a * ((Vector4)b);

        public static Vector4 operator /(IntVector4 a, float b) => ((Vector4)a) / b;

        public static Vector4 operator +(IntVector4 a, float b) => ((Vector4)a) + new Vector4(b, b, b, b);

        public static Vector4 operator +(float a, IntVector4 b) => new Vector4(a, a, a, a) + ((Vector4)b);

        public static Vector4 operator -(IntVector4 a, float b) => ((Vector4)a) - new Vector4(b, b, b, b);

        public static Vector4 operator -(float a, IntVector4 b) => new Vector4(a, a, a, a) - ((Vector4)b);
#endif

        // IntVector (op) IntVector

        public static IntVector4 operator +(IntVector4 a, IntVector4 b) => new IntVector4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);

        public static IntVector4 operator -(IntVector4 a, IntVector4 b) => new IntVector4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);

        public static IntVector4 operator *(IntVector4 left, IntVector4 right) => new IntVector4(left.x * right.x, left.y * right.y, left.z * right.z, left.w * right.w);

        public static IntVector4 operator /(IntVector4 left, IntVector4 right) => new IntVector4(left.x / right.x, left.y / right.y, left.z / right.z, left.w / right.w);

#if UNITY
        // IntVector (op) Vector

        public static Vector4 operator +(IntVector4 a, Vector4 b) => (Vector4)a + b;

        public static Vector4 operator +(Vector4 a, IntVector4 b) => a + (Vector4)b;

        public static Vector4 operator -(IntVector4 a, Vector4 b) => (Vector4)a - b;

        public static Vector4 operator -(Vector4 a, IntVector4 b) => a - (Vector4)b;

        public static Vector4 operator *(IntVector4 left, Vector4 right) => new Vector4(left.x * right.x, left.y * right.y, left.z * right.z, left.w * right.w);

        public static Vector4 operator *(Vector4 left, IntVector4 right) => new Vector4(left.x * right.x, left.y * right.y, left.z * right.z, left.w * right.w);

        public static Vector4 operator /(IntVector4 left, Vector4 right) => new Vector4(left.x / right.x, left.y / right.y, left.z / right.z, left.w / right.w);

        public static Vector4 operator /(Vector4 left, IntVector4 right) => new Vector4(left.x / right.x, left.y / right.y, left.z / right.z, left.w / right.w);
#endif
    }
}