using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class InstallPackages : EditorWindow
{
    private static readonly string AssetRootPath = Path.Combine
    (
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "Unity"
    );

    [SerializeField]
    private List<string> Packages = new List<string>(new[]
    {
        "DOTween HOTween v2",
        "Rainbow Folders 2",
        "Technie Collider Creator",
        "Amplify Shader Editor",
        "VR Tunnelling Pro"
    });

    [SerializeField]
    private Vector2 scrollPos = Vector2.zero;

    // Potential Bug #1: This is a bug because Unity does not serialize Dictionary<TKey, TValue> fields through SerializeReference, so a domain reload can discard this lookup or restore it as null.
    // Suggested Fix: Remove [SerializeReference] and create the dictionary as nonserialized transient state inside the install operation.
    // Related: #2.
    [SerializeReference]
    private Dictionary<string, string> FullPathLookups = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase);

    [MenuItem("Tools/Install Packages")]
    private static void CreateInstallPackagesWindow()
    {
        GetWindow<InstallPackages>();
    }

    private IEnumerable<string> SearchForPackages(string folder)
    {
        // Potential Bug #2: This is a bug because an inaccessible or invalid directory anywhere below the Unity application-data folder throws and aborts the entire package search.
        // Suggested Fix: Catch expected IO exceptions per directory, report the skipped path, and continue traversing accessible directories.
        // Related: #1, #4.
        foreach (var x in Directory.GetFiles(folder))
        {
            if (Path.GetExtension(x).ToUpperInvariant() == ".UNITYPACKAGE")
            {
                var y = Path.GetFileNameWithoutExtension(x)?.Trim();
                if (!string.IsNullOrWhiteSpace(y))
                {
                    FullPathLookups[y] = x;
                    yield return y;
                }
            }
        }

        foreach (var d in Directory.GetDirectories(folder))
        {
            foreach (var pkg in SearchForPackages(d)) { yield return pkg; }
        }
    }

    private void OnGUI()
    {
        var target = this as ScriptableObject;
        var so = new SerializedObject(target);
        var stringsProperty = so.FindProperty(nameof(Packages));

        // Potential Bug #3: This is a bug because edits made through PropertyField remain in the SerializedObject copy and are not written back to Packages before the Install button reads it.
        // Suggested Fix: Call so.Update() before drawing the property and so.ApplyModifiedProperties() immediately after drawing it.
        // Related: #1.
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
        EditorGUILayout.PropertyField(stringsProperty, true);
        EditorGUILayout.EndScrollView();

        GUI.enabled = Packages.Any();
        if (GUILayout.Button("Install"))
        {
            FullPathLookups.Clear();
            SearchForPackages(AssetRootPath).ToArray();

            foreach (var pkg in Packages)
            {
                if (string.IsNullOrWhiteSpace(pkg)) { continue; }
                var pkgTrim = pkg.Trim();
                if (!FullPathLookups.ContainsKey(pkgTrim))
                {
                    Debug.LogError($"Unable to find package: '{pkgTrim}'.");
                }
                else
                {
                    Debug.Log($"Installing Package: '{pkgTrim}' . . .");
                    // Potential Bug #4: This is a bug because validation uses the trimmed key but lookup uses the original string, so leading or trailing whitespace causes a KeyNotFoundException after validation succeeds.
                    // Suggested Fix: Use AssetDatabase.ImportPackage(FullPathLookups[pkgTrim], false).
                    // Related: #2.
                    AssetDatabase.ImportPackage(FullPathLookups[pkg], false);
                }
            }

            Close();
        }
        GUI.enabled = true;
    }
}