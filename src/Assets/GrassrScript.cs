using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class GrassrScript : MonoBehaviour
{
    public Shader shader;
    public Texture mainTexture;

    List<Vector4> points;
    Material material;
    ComputeBuffer buffer;

    /// <summary>
    /// 初期化
    /// </summary>
    void OnEnable()
    {
        material = new Material(shader);
        material.SetTexture("_MainTex", mainTexture);

        int NUM_X = 64;
        int NUM_Z = 64;

        points = new List<Vector4>();
        for (int z = 0; z < NUM_Z; z++)
        {
            for (int x = 0; x < NUM_X; x++)
            {
                points.Add(new Vector4(
                    // -5から-5に少しまばらに植える
                    10.0f * (((float)x + Random.value - 0.5f)/(float)NUM_X - 0.5f),
                    Random.value * 0.7f + 0.3f,// 高さの変数を入れる
                    10.0f * (((float)z + Random.value - 0.5f)/(float)NUM_Z - 0.5f),
                    Random.value * 2.0f// 彩度の情報を入れる[0-2]
                    ));
            }
        }

        buffer = new ComputeBuffer(
            points.Count, 
            Marshal.SizeOf(typeof(Vector4)), 
            ComputeBufferType.Default);
        buffer.SetData(points);
        material.SetBuffer("points", buffer);
    }

    void OnDisable()
    {
        points.Clear();
        buffer.Release();
    }

    /// <summary>
    /// レンダリング
    /// </summary>
    void OnRenderObject()
    {
        material.SetPass(0);
        Graphics.DrawProceduralNow(MeshTopology.Points, points.Count);
    }
}
