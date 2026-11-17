using System;
using UnityEngine;
using UnityEngine.Events;
public sealed class DistanceTracker : MonoBehaviour
{
    [System.Serializable] public class DistanceEvent : UnityEvent<int> { }
    [SerializeField] Transform player; [SerializeField] float metresPerUnityUnit = 1f; [SerializeField] int[] milestonesMetres = { 5000, 10000, 15000, 20000 }; [SerializeField] DistanceEvent onMilestone = new DistanceEvent();
    float startZ; int nextMilestoneIndex; public float DistanceMetres { get; private set; } public DistanceEvent OnMilestone => onMilestone;
    public void Configure(Transform target) { player = target; }
    void Start() { if (player == null) { Debug.LogError("DistanceTracker: Player reference missing."); enabled = false; return; } Array.Sort(milestonesMetres); startZ = player.position.z; }
    void Update() { if (player == null) return; DistanceMetres = Mathf.Max(0f, (player.position.z - startZ) * metresPerUnityUnit); while (nextMilestoneIndex < milestonesMetres.Length && DistanceMetres >= milestonesMetres[nextMilestoneIndex]) { onMilestone.Invoke(milestonesMetres[nextMilestoneIndex]); nextMilestoneIndex++; } }
}
