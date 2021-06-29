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

    [SerializeReference]
    private Dictionary<string, string> FullPathLookups = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase);

    [MenuItem("Tools/Install Packages")]
    private static void CreateInstallPackagesWindow()
    {
        GetWindow<InstallPackages>();
    }

    private IEnumerable<string> SearchForPackages(string folder)
    {
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
                    AssetDatabase.ImportPackage(FullPathLookups[pkg], false);
                }
            }

            Close();
        }
        GUI.enabled = true;
    }
}