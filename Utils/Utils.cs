using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class Utils
{
    private const string PlayerTag = "Player";

    public static IEnumerable<T> NotNull<T>(this IEnumerable<T> items) where T : class
    {
        if (items == null) { return Array.Empty<T>(); }
        return items.Where(x => x != null);
    }

    public static GameObject IsCollidingWithPlayer(this CollisionDetector cd)
    {
        if (cd)
        {
            foreach (var cw in cd.CollidingWith)
            {
                var plr = cw.gameObject.FindAncestorsWithTag(PlayerTag).FirstOrDefault();
                if (plr) { return plr; }
            }
        }

        return null;
    }

    public static GameObject IsCollidingWithPlayer(this Collider col, bool allowTriggerColliders = true, LayerMask? layerMask = null)
    {
        if (col)
        {
            foreach (var cw in col.Overlap(layerMask))
            {
                if (cw.isTrigger && !allowTriggerColliders) { continue; }
                var plr = cw.gameObject.FindAncestorsWithTag(PlayerTag).FirstOrDefault();
                if (plr) { return plr; }
            }
        }

        return null;
    }

    public static T IsCollidingWith<T>(this CollisionDetector cd)
        where T : MonoBehaviour
    {
        if (cd)
        {
            foreach (var cw in cd.CollidingWith)
            {
                var o = cw.GetComponentInParent<T>();
                if (o) { return o; }

                foreach (var col in cd.GetCollders(cw))
                {
                    o = col.GetComponentInParent<T>();
                    if (o) { return o; }
                }
            }
        }

        return null;
    }

    public static Vector3 Average(this IEnumerable<Vector3> points)
    {
        var avg = Vector3.zero;
        float total = 0;

        if (points != null)
        {
            foreach (var pt in points)
            {
                avg += pt;
                total++;
            }
        }

        return new Vector3(avg.x / total, avg.y / total, avg.z / total);
    }

    public static Vector3 GetRandomPoint(this GameObject obj)
    {
        var colliders = obj.GetComponentsInChildren<Collider>();
        var count = colliders.Length;

        var minX = float.MaxValue;
        var maxX = float.MinValue;
        var minY = float.MaxValue;
        var maxY = float.MinValue;
        var minZ = float.MaxValue;
        var maxZ = float.MinValue;

        for (int i = 0; i < count; i++)
        {
            var collider = colliders[i];
            if (!collider.gameObject.activeInHierarchy) { continue; }
            if (collider.isTrigger) { continue; }

            var tx = collider.transform.localToWorldMatrix;

            var b = collider.bounds;
            var apt = tx.MultiplyPoint((b.center - (b.size / 2f)));
            var bpt = tx.MultiplyPoint((b.center + (b.size / 2f)));

            minX = Mathf.Min(minX, apt.x, bpt.x);
            minY = Mathf.Min(minY, apt.y, bpt.y);
            minZ = Mathf.Min(minZ, apt.z, bpt.z);

            maxX = Mathf.Max(maxX, apt.x, bpt.x);
            maxY = Mathf.Max(maxY, apt.y, bpt.y);
            maxZ = Mathf.Max(maxZ, apt.z, bpt.z);
        }

        var pt = new Vector3
        (
            UnityEngine.Random.Range(minX, maxX),
            UnityEngine.Random.Range(minY, maxY),
            UnityEngine.Random.Range(minZ, maxZ)
        );

        return obj.GetClosestPoint(pt);
    }

    public static Vector3 GetClosestPoint(this GameObject obj, Vector3 targetPos)
    {
        if (obj == null) { return targetPos; }

        var colliders = obj.GetComponentsInChildren<Collider>();
        var count = colliders.Length;
        var dist = float.MaxValue;
        var bestMatch = targetPos;
        for (int i = 0; i < count; i++)
        {
            var collider = colliders[i];

            if (!collider.gameObject.activeInHierarchy) { continue; }
            if (collider.isTrigger) { continue; }

            var pos = collider.ClosestPoint(targetPos);
            var nd = (targetPos - pos).sqrMagnitude;
            if (nd < dist) { dist = nd; bestMatch = pos; }
        }

        return bestMatch;
    }

    public static RaycastHit? TryCast(Vector3 pos, Vector3 dir, float maxDistance)
    {
        if (Physics.Raycast(pos, dir, out var hitInfo, maxDistance, Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore))
        {
            return hitInfo;
        }

        //foreach (var hit in Physics.RaycastAll(pos, dir, maxDistance, Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore))
        //{
        //    if (!hit.collider.enabled) { continue; }
        //    if (!hit.collider.gameObject.activeInHierarchy) { continue; }
        //    return hit;
        //}

        return null;
    }

    public static bool Ensure<T>(this GameObject go, ref T item, bool searchParents = false)
        where T : Component
    {
        if (item == null)
        {
            if (searchParents)
            {
                item = go.GetComponentInParent<T>();
            }
            else
            {
                item = go.GetComponent<T>();
            }
        }

        return (item != null);
    }

    public static IEnumerable<GameObject> GetHierarchy(this GameObject gbo)
    {
        if (gbo)
        {
            yield return gbo;

            var pt = gbo.transform.parent;
            if (pt)
            {
                foreach (var p in pt.gameObject.GetHierarchy())
                {
                    yield return p;
                }
            }
        }
    }

    public static void IgnoreCollision(this Rigidbody @this, Collider collider, bool ignore = true)
    {
        if (@this && collider)
        {
            var acs = @this.GetComponentsInChildren<Collider>().ToList();
            foreach (var ac in acs)
            {
                Physics.IgnoreCollision(ac, collider, ignore);
            }

            if (ignore)
            {
                var colliderParents = collider.gameObject.GetHierarchy().ToList();
                foreach (var cd in @this.GetComponentsInChildren<CollisionDetector>())
                {
                    foreach (var cp in colliderParents)
                    {
                        cd.CollidingAt.Remove(cp);
                    }
                }

                var rbc = @this.GetComponentsInChildren<Collider>();
                foreach (var cd in collider.gameObject.GetComponentsInParent<CollisionDetector>())
                {
                    foreach (var col in rbc)
                    {
                        cd.CollidingAt.Remove(col.gameObject);
                    }
                }
            }
        }
    }

    public static void EnsureBgRunner()
    {
        if (!BgRunner.Instance)
        {
            try
            {
                var bgRunner = new GameObject("BgRunner").AddComponent<BgRunner>();
                bgRunner.Awake(); // force it to get assigned.
            }
            catch
            {
                /* maybe this will work? */
            }
        }
    }

    public static void IgnoreCollision(this Rigidbody @this, Rigidbody other, bool ignore = true)
    {
        // Call this inside of an enumerator, because if you're in a collision callback right now,
        // some of the calls won't be honored.

        bool doAdvanced = BgRunner.TryRunCoRoutine(__IgnoreCollision(@this, other, ignore, true)) == null;

        // but also Call it right away so that we can get most of the collisions honored.
        var e = __IgnoreCollision(@this, other, ignore, doAdvanced);
        while (e.MoveNext()) ;
    }

    private static IEnumerator __IgnoreCollision(this Rigidbody body1, Rigidbody body2, bool ignore, bool doAdvanced)
    {
        yield return null;

        if (!body1 || !body2) { yield break; }
        var acs = body1.GetComponentsInChildren<Collider>().ToList();
        yield return null;

        if (!body1 || !body2) { yield break; }
        var bcs = body2.GetComponentsInChildren<Collider>().ToList();
        yield return null;

        foreach (var ac in acs)
        {
            foreach (var bc in bcs)
            {
                if (ac && bc)
                {
                    Physics.IgnoreCollision(ac, bc, ignore);
                }
            }
        }

        // Clear out any cached collisions
        if (ignore && doAdvanced)
        {
            yield return null;

            if (!body1 || !body2) { yield break; }

            foreach (var acd in body1.GetComponentsInChildren<CollisionDetector>())
            {
                if (acd)
                {
                    foreach (var bc in bcs)
                    {
                        if (bc && bc.gameObject)
                        {
                            acd.CollidingAt.Remove(bc.gameObject);
                        }
                    }
                }
            }

            yield return null;

            if (!body1 || !body2) { yield break; }

            foreach (var bcd in body2.GetComponentsInChildren<CollisionDetector>())
            {
                if (bcd)
                {
                    foreach (var ac in acs)
                    {
                        if (ac && ac.gameObject)
                        {
                            bcd.CollidingAt.Remove(ac.gameObject);
                        }
                    }
                }
            }
        }
    }

    public static void KnockBackBody(this Rigidbody @this, Vector3 pos, float force)
    {
        if (@this)
        {
            var dir = @this.transform.position - pos;
            dir = Vector3.ProjectOnPlane(dir, ActualUp).normalized;
            dir *= force;

            KnockBackDir(@this, dir);
        }
    }

    public static void KnockBackDir(this Rigidbody @this, Vector3 dir)
    {
        if (@this)
        {
            var co = BgRunner.TryRunCoRoutine(__AddForce(@this, dir));
            if (co == null)
            {
                var e = __AddForce(@this, dir);
                while (e.MoveNext()) ;
            }
        }
    }

    private static IEnumerator __AddForce(Rigidbody rb, Vector3 force)
    {
        yield return new WaitForFixedUpdate();
        rb.MovePosition(rb.transform.position + (force.normalized + ActualUp).normalized * .05f);
        yield return new WaitForFixedUpdate();
        rb.AddForce(force, ForceMode.VelocityChange);
    }

    public static bool IsOutOfBounds(Vector3 pos)
    {
        if (pos.y < -10f) { return true; }

        //if (SceneManager.GetActiveScene().buildIndex == (int)SceneIdx.Maze1)
        //{
        //    if (pos.x > 20) { return true; }
        //    if (pos.x < -25) { return true; }
        //    if (pos.z < -20) { return true; }
        //    if (pos.z > 25) { return true; }
        //    if (pos.y > 30) { return true; }
        //}

        return false;
    }

    private static Dictionary<Vector3, Vector3> UpCache = new Dictionary<Vector3, Vector3>();

    public static Vector3 ActualUp
    {
        get
        {
            var key = Physics.gravity;
            if (!UpCache.ContainsKey(key))
            {
                UpCache[key] = -(Physics.gravity.normalized);
            }
            return UpCache[key];
        }
    }

    public static Vector2 ToLatitudeAndLongitude(this Vector3 pos)
    {
        pos.Normalize();
        var y = Mathf.Asin(pos.y) * (2f / Mathf.PI);
        var x = Mathf.Atan2(pos.x, pos.z) / Mathf.PI;
        return new Vector2(x, y);
    }

    public static Vector3 ToSphericalCoords(this Vector2 latLong)
    {
        var lat = latLong.y;
        var lng = latLong.x;

        lng *= Mathf.PI;
        lat *= Mathf.PI / 2f;

        lat = (Mathf.PI / 2f) - lat;

        return new Vector3
        (
            Mathf.Sin(lat) * Mathf.Sin(lng),
            Mathf.Cos(lat),
            Mathf.Sin(lat) * Mathf.Cos(lng)
        );
    }

    public static float DeltaTwoTao(float tao1, float tao2)
    {
        return Mathf.DeltaAngle((tao1 + 1f) * 360f, (tao2 + 1f) * 360f) / 180f;
    }

    public static float LerpTo(this float current, float desired, float time)
    {
        return Mathf.Lerp(current, desired, .1f * 90f * time);
    }

    public static IEnumerable<GameObject> FindAncestorsWithTag(this GameObject parent, string tag)
    {
        if (parent)
        {
            if (parent.CompareTag(tag)) { yield return parent; }
            if (parent.transform && parent.transform.parent)
            {
                foreach (var anc in parent.transform.parent.gameObject.FindAncestorsWithTag(tag))
                {
                    yield return anc;
                }
            }
        }
    }

    public static IEnumerable<GameObject> FindChildrenWithTag(this GameObject parent, string tag)
    {
        if (parent)
        {
            var t = parent.transform;
            if (t.CompareTag(tag)) { yield return t.gameObject; }

            foreach (Transform tr in t)
            {
                foreach (var result in tr.gameObject.FindChildrenWithTag(tag))
                {
                    yield return result;
                }
            }
        }
    }

    public static T FindComponentInChildWithTag<T>(this GameObject parent, string tag) where T : Component
    {
        Transform t = parent.transform;
        foreach (Transform tr in t)
        {
            if (tr.CompareTag(tag))
            {
                return tr.GetComponent<T>();
            }
            else
            {
                if (tr.gameObject && tr.gameObject != parent)
                {
                    var value = tr.gameObject.FindComponentInChildWithTag<T>(tag);
                    if (value) { return value; }
                }
            }
        }

        return null;
    }

    public static IEnumerable<Collider> Overlap(this Collider col, LayerMask? layerMask = null)
    {
        if (col)
        {
            if (col is SphereCollider sc && sc)
            {
                return sc.Overlap(layerMask);
            }
            else if (col is BoxCollider bc && bc)
            {
                return bc.Overlap(layerMask);
            }
            else if (col is CapsuleCollider cc && cc)
            {
                return cc.Overlap(layerMask);
            }
        }

        Debug.LogError("Overlap used with unsupported collider type: " + (col ? col.GetType().Name : "[null]"));
        return Array.Empty<Collider>();
    }

    public static Vector2 Mult(this Vector2 a, Vector2 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        return a;
    }

    public static Vector2 Mult(this Vector2 a, Vector3 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        return a;
    }

    public static Vector2 Mult(this Vector2 a, Vector4 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        return a;
    }

    public static Vector3 Mult(this Vector3 a, Vector2 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        return a;
    }

    public static Vector3 Mult(this Vector3 a, Vector3 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        a.z *= b.z;
        return a;
    }

    public static Vector3 Mult(this Vector3 a, Vector4 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        a.z *= b.z;
        return a;
    }

    public static Vector4 Mult(this Vector4 a, Vector2 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        return a;
    }

    public static Vector4 Mult(this Vector4 a, Vector3 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        a.z *= b.z;
        return a;
    }

    public static Vector4 Mult(this Vector4 a, Vector4 b)
    {
        a.x *= b.x;
        a.y *= b.y;
        a.z *= b.z;
        a.w *= b.w;
        return a;
    }

    public static Vector2 Abs(this Vector2 a)
    {
        a.x = Mathf.Abs(a.x);
        a.y = Mathf.Abs(a.y);

        return a;
    }

    public static Vector3 Abs(this Vector3 a)
    {
        a.x = Mathf.Abs(a.x);
        a.y = Mathf.Abs(a.y);
        a.z = Mathf.Abs(a.z);

        return a;
    }

    public static Vector4 Abs(this Vector4 a)
    {
        a.x = Mathf.Abs(a.x);
        a.y = Mathf.Abs(a.y);
        a.z = Mathf.Abs(a.z);
        a.w = Mathf.Abs(a.w);

        return a;
    }

    public static IEnumerable<Collider> Overlap(this SphereCollider sph, LayerMask? layerMask = null)
    {
        var mat = sph.gameObject.transform.localToWorldMatrix;
        var pos = mat.MultiplyPoint(sph.center);

        var scale = mat.lossyScale;
        var radius = sph.radius * Mathf.Max(scale.x, scale.y, scale.z);

        return
        (
            layerMask.HasValue
            ? Physics.OverlapSphere(pos, radius, layerMask.Value)
            : Physics.OverlapSphere(pos, radius)
        )
        .Where(c => c != sph);
    }

    public static IEnumerable<Collider> Overlap(this BoxCollider box, LayerMask? layerMask = null)
    {
        var mat = box.gameObject.transform.localToWorldMatrix;
        var pos = mat.MultiplyPoint(box.center);

        var scale = mat.lossyScale;

        var size = box.size;
        size.x *= scale.x;
        size.y *= scale.y;
        size.z *= scale.z;

        return
        (
            layerMask.HasValue
            ? Physics.OverlapBox(pos, size / 2, box.transform.rotation, layerMask.Value)
            : Physics.OverlapBox(pos, size / 2, box.transform.rotation)
        )
        .Where(c => c != box);
    }

    public static IEnumerable<Collider> Overlap(this CapsuleCollider capsule, LayerMask? layerMask = null)
    {
        var mat = capsule.gameObject.transform.localToWorldMatrix;
        var pos = mat.MultiplyPoint(capsule.center);

        // direction values: X = 0, Y = 1, Z = 2
        var direction = capsule.direction == 0 ? Vector3.right
                    : capsule.direction == 1 ? Vector3.up
                    : Vector3.forward;

        var p0 = mat.MultiplyVector(direction * capsule.height / 2f);
        var p1 = pos - p0;
        p0 += pos;

        var a2 = Vector3.right;
        if (a2 == direction) { a2 = Vector3.up; }
        var a3 = Vector3.Cross(direction, a2).Abs();

        var radius = Mathf.Sqrt
        (
            Mathf.Max
            (
                mat.MultiplyVector(a2 * capsule.radius).sqrMagnitude,
                mat.MultiplyVector(a3 * capsule.radius).sqrMagnitude
            )
        );

        return
        (
            layerMask.HasValue
            ? Physics.OverlapCapsule(p0, p1, radius, layerMask.Value)
            : Physics.OverlapCapsule(p0, p1, radius)
        )
        .Where(c => c != capsule);
    }
}