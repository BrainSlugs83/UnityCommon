using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Glow : MonoBehaviour
{
    public bool IsGlowing = true;

    private Vector2 MoveDir = Vector2.zero;
    private HashSet<Material> materials = new HashSet<Material>();

    // Update is called once per frame
    private void Update()
    {
        if (IsGlowing)
        {
            bool reset = false;

            if (!materials.Any())
            {
                reset = true;

                foreach (var mr in GetComponentsInChildren<MeshRenderer>())
                {
                    if (mr.material)
                    {
                        materials.Add(mr.material);
                    }
                    else if (mr.sharedMaterial)
                    {
                        materials.Add(mr.sharedMaterial);
                    }
                }
            }

            foreach (var m in materials)
            {
                if (reset)
                {
                    if (m.HasProperty("_Cutoff")) { m.SetFloat("_Cutoff", Random.Range(.4f, .6f)); }
                    if (m.HasProperty("_CutoffMultiply")) { m.SetFloat("_CutoffMultiply", Random.Range(8f, 12f)); }
                }

                if (m.HasProperty("_NoiseTex"))
                {
                    if (reset)
                    {
                        m.SetTextureOffset("_NoiseTex", new Vector2(Random.Range(-10f, 10f), Random.Range(-10f, 10f)));
                        MoveDir = new Vector2(Random.Range(-10f, 10f), Random.Range(-10f, 10f));
                        MoveDir.Normalize();
                        MoveDir *= .1f;
                    }
                    else
                    {
                        var offset = m.GetTextureOffset("_NoiseTex");
                        m.SetTextureOffset("_NoiseTex", offset + (MoveDir * Time.deltaTime));

                        var dir = Mathf.Atan2(MoveDir.y, MoveDir.x);
                        dir += (Random.Range(-.5f, .5f) / 180f) * Mathf.PI;

                        MoveDir.x = Mathf.Cos(dir);
                        MoveDir.y = Mathf.Sin(dir);

                        MoveDir.Normalize();
                        MoveDir *= .1f;
                    }
                }
            }
        }
        else
        {
            if (materials.Any())
            {
                foreach (var m in materials)
                {
                    if (m.HasProperty("_Cutoff")) { m.SetFloat("_Cutoff", 1f); }
                    if (m.HasProperty("_CutoffMultiply")) { m.SetFloat("_CutoffMultiply", 1f); }
                }

                materials.Clear();
            }
        }
    }
}