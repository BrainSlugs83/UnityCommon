using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UnityCommon
{
    [Flags]
    public enum Directions
    {
        Forward = 1,
        Right = 2,
        Backward = 4,
        Left = 8,
        Up = 16,
        Down = 32
    }
}