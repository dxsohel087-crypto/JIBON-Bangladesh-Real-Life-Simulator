using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Recycles road prefabs ahead of the runner to create an endless track.
/// Assign road prefabs with identical segment lengths in the Inspector.
/// </summary>
public sealed class EndlessRoadSpawner : MonoBehaviour
{
    [SerializeField] private Transform player;
    [SerializeField] private GameObject[] roadPrefabs;
    [SerializeField] private float segmentLength = 30f;
    [SerializeField] private int segmentsAhead = 7;
    [SerializeField] private int segmentsBehind = 2;

    private readonly Queue<GameObject> activeSegments = new Queue<GameObject>();
    private float nextSpawnZ;

    private void Start()
    {
        if (player == null || roadPrefabs == null || roadPrefabs.Length == 0 || segmentLength <= 0f)
        {
            Debug.LogError("EndlessRoadSpawner: assign Player, road prefabs and a positive segment length.");
            enabled = false;
            return;
        }

        nextSpawnZ = 0f;
        for (int i = 0; i < segmentsAhead; i++) SpawnSegment();
    }

    private void Update()
    {
        while (player.position.z + segmentsAhead * segmentLength > nextSpawnZ)
            SpawnSegment();

        while (activeSegments.Count > segmentsAhead + segmentsBehind)
        {
            GameObject oldest = activeSegments.Peek();
            if (oldest.transform.position.z + segmentLength >= player.position.z - segmentsBehind * segmentLength)
                break;

            activeSegments.Dequeue();
            Destroy(oldest);
        }
    }

    private void SpawnSegment()
    {
        GameObject prefab = roadPrefabs[Random.Range(0, roadPrefabs.Length)];
        GameObject segment = Instantiate(prefab, new Vector3(0f, 0f, nextSpawnZ), Quaternion.identity, transform);
        activeSegments.Enqueue(segment);
        nextSpawnZ += segmentLength;
    }
}
