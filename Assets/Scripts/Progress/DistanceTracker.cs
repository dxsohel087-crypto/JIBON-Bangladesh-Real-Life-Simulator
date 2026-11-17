using UnityEngine;
using UnityEngine.Events;

/// <summary>Tracks metres travelled and announces configured food/rest milestones.</summary>
public sealed class DistanceTracker : MonoBehaviour
{
    [System.Serializable] public class DistanceEvent : UnityEvent<int> { }

    [SerializeField] private Transform player;
    [SerializeField] private float metresPerUnityUnit = 1f;
    [SerializeField] private int[] milestonesMetres = { 5000, 10000, 15000, 20000 };
    [SerializeField] private DistanceEvent onMilestone = new DistanceEvent();

    private float startZ;
    private int nextMilestoneIndex;

    public float DistanceMetres { get; private set; }
    public DistanceEvent OnMilestone => onMilestone;

    private void Start()
    {
        if (player == null)
        {
            Debug.LogError("DistanceTracker: assign the player Transform.");
            enabled = false;
            return;
        }
        startZ = player.position.z;
    }

    private void Update()
    {
        DistanceMetres = Mathf.Max(0f, (player.position.z - startZ) * metresPerUnityUnit);
        while (nextMilestoneIndex < milestonesMetres.Length &&
               DistanceMetres >= milestonesMetres[nextMilestoneIndex])
        {
            onMilestone.Invoke(milestonesMetres[nextMilestoneIndex]);
            nextMilestoneIndex++;
        }
    }
}
