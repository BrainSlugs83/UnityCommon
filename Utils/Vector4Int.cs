namespace UnityEngine
{
    public struct Vector4Int
    {
        public static Vector4Int zero => default;
        public static Vector4Int one => new Vector4Int(1, 1, 1, 1);

        public int x;
        public int y;
        public int z;
        public int w;

        public Vector4Int(int x, int y, int z, int w)
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
            return new Vector4(x, y, z, w).GetHashCode();
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(obj, null)) { return false; }
            else if (obj is Vector4Int iv)
            {
                return iv.x == x && iv.y == y && iv.z == z && iv.w == w;
            }
            else if (obj is Vector4 v)
            {
                return new Vector4(x, y, z, w) == v;
            }
            else
            {
                return false;
            }
        }

        public static bool operator ==(Vector4Int a, object b) => a.Equals(b);

        public static bool operator !=(Vector4Int a, object b) => !a.Equals(b);

        public static implicit operator Vector4Int(int i) => zero + i;

        public static implicit operator Vector4(Vector4Int iv) => new Vector4(iv.x, iv.y, iv.z, iv.w);

        public static explicit operator Vector4Int(Vector4 v) => new Vector4Int((int)v.x, (int)v.y, (int)v.z, (int)v.w);

        public static explicit operator IntVector2(Vector4Int v) => new IntVector2(v.x, v.y);

        public static explicit operator IntVector3(Vector4Int v) => new IntVector3(v.x, v.y, v.z);

        public static explicit operator Vector4Int(IntVector2 v) => new Vector4Int(v.x, v.y, 0, 0);

        public static explicit operator Vector4Int(IntVector3 v) => new Vector4Int(v.x, v.y, v.z, 0);

        // IntVector (op) Int
        public static Vector4Int operator *(Vector4Int a, int b) => new Vector4Int(a.x * b, a.y * b, a.z * b, a.w * b);

        public static Vector4Int operator *(int a, Vector4Int b) => new Vector4Int(a * b.x, a * b.y, a * b.z, a * b.w);

        public static Vector4Int operator /(Vector4Int a, int b) => new Vector4Int(a.x / b, a.y / b, a.z / b, a.w / b);

        public static Vector4Int operator +(Vector4Int a, int b) => new Vector4Int(a.x + b, a.y + b, a.z + b, a.w + b);

        public static Vector4Int operator +(int a, Vector4Int b) => new Vector4Int(a + b.x, a + b.y, a + b.z, a + b.w);

        public static Vector4Int operator -(Vector4Int a, int b) => new Vector4Int(a.x - b, a.y - b, a.z - b, a.w - b);

        public static Vector4Int operator -(int a, Vector4Int b) => new Vector4Int(a - b.x, a - b.y, a - b.z, a - b.w);

        // IntVector (op) Float
        public static Vector4 operator *(Vector4Int a, float b) => ((Vector4)a) * b;

        public static Vector4 operator *(float a, Vector4Int b) => a * ((Vector4)b);

        public static Vector4 operator /(Vector4Int a, float b) => ((Vector4)a) / b;

        public static Vector4 operator +(Vector4Int a, float b) => ((Vector4)a) + new Vector4(b, b, b, b);

        public static Vector4 operator +(float a, Vector4Int b) => new Vector4(a, a, a, a) + ((Vector4)b);

        public static Vector4 operator -(Vector4Int a, float b) => ((Vector4)a) - new Vector4(b, b, b, b);

        public static Vector4 operator -(float a, Vector4Int b) => new Vector4(a, a, a, a) - ((Vector4)b);

        // IntVector (op) IntVector

        public static Vector4Int operator +(Vector4Int a, Vector4Int b) => new Vector4Int(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);

        public static Vector4Int operator -(Vector4Int a, Vector4Int b) => new Vector4Int(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);

        public static Vector4Int operator *(Vector4Int left, Vector4Int right) => new Vector4Int(left.x * right.x, left.y * right.y, left.z * right.z, left.w * right.w);

        public static Vector4Int operator /(Vector4Int left, Vector4Int right) => new Vector4Int(left.x / right.x, left.y / right.y, left.z / right.z, left.w / right.w);

        // IntVector (op) Vector

        public static Vector4 operator +(Vector4Int a, Vector4 b) => (Vector4)a + b;

        public static Vector4 operator +(Vector4 a, Vector4Int b) => a + (Vector4)b;

        public static Vector4 operator -(Vector4Int a, Vector4 b) => (Vector4)a - b;

        public static Vector4 operator -(Vector4 a, Vector4Int b) => a - (Vector4)b;

        public static Vector4 operator *(Vector4Int left, Vector4 right) => new Vector4(left.x * right.x, left.y * right.y, left.z * right.z, left.w * right.w);

        public static Vector4 operator *(Vector4 left, Vector4Int right) => new Vector4(left.x * right.x, left.y * right.y, left.z * right.z, left.w * right.w);

        public static Vector4 operator /(Vector4Int left, Vector4 right) => new Vector4(left.x / right.x, left.y / right.y, left.z / right.z, left.w / right.w);

        public static Vector4 operator /(Vector4 left, Vector4Int right) => new Vector4(left.x / right.x, left.y / right.y, left.z / right.z, left.w / right.w);
    }
}