using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DarknessShader : MonoBehaviour
{
    public float DesiredCutOff = 1.0f;

    public float CurrentCutOff { get; private set; }

    public float FadeSpeed = .025f;

    public bool ModifyColorOpacity = false;

    private MeshRenderer mr;
    //private RawImage img;

    private static float GetNext(float current, float goal, float speed)
    {
        var step = (goal - current) * speed * Time.fixedDeltaTime * 90f;
        current += step;

        if (Mathf.Abs(step) < .001f)
        {
            current = goal;
        }

        return current;
    }

    private void Awake()
    {
        gameObject.Ensure(ref mr, false);
        if (mr) { mr.enabled = true; }
        //gameObject.Ensure(ref img, false);
    }

    public void ForceCutOff(float newValue)
    {
        if (mr)
        {
            foreach (var mat in mr.materials)
            {
                if (mat.HasProperty("_Cutoff"))
                {
                    mat.SetFloat("_Cutoff", newValue);
                }
                else if (mat.HasProperty("_Color"))
                {
                    var clr = mat.GetColor("_Color");
                    clr.a = newValue;
                    mat.SetColor("_Color", clr);
                }

                this.CurrentCutOff = newValue;
            }

            this.DesiredCutOff = newValue;
            mr.enabled = (CurrentCutOff != 0f) || (DesiredCutOff != 0f);
        }
    }

    public void FixedUpdate()
    {
        var fadeGoal = Mathf.Clamp(DesiredCutOff, 0f, 1f);

        if (mr)
        {
            if (DesiredCutOff != 0) { mr.enabled = true; }

            foreach (var mat in mr.materials)
            {
                if (mat.HasProperty("_Cutoff"))
                {
                    float currentCutOff = mat.GetFloat("_Cutoff");
                    currentCutOff = GetNext(currentCutOff, fadeGoal, FadeSpeed);
                    mat.SetFloat("_Cutoff", currentCutOff);
                    this.CurrentCutOff = currentCutOff;
                }
                else if (mat.HasProperty("_Color"))
                {
                    var clr = mat.GetColor("_Color");
                    float currentCutOff = clr.a;
                    this.CurrentCutOff = clr.a = GetNext(currentCutOff, fadeGoal, FadeSpeed);
                    mat.SetColor("_Color", clr);
                }
            }

            mr.enabled = (CurrentCutOff != 0f) || (DesiredCutOff != 0f);
        }

        //if (img)
        //{
        //    float current = img.color.a;
        //    current = GetNext(current, fadeGoal, FadeSpeed);
        //    img.color = new Color(img.color.r, img.color.g, img.color.b, current);
        //    CurrentCutOff = current;
        //}
    }
}