using UnityEngine;
using UnityEngine.Events;

/// <summary>
/// Pauses the run at distance milestones. Connect OnBreakStarted to the food-break UI
/// and call ResumeRun from its Resume button.
/// </summary>
public sealed class FoodBreakManager : MonoBehaviour
{
    [System.Serializable] public class BreakEvent : UnityEvent<int> { }

    [SerializeField] private RunnerController runner;
    [SerializeField] private BreakEvent onBreakStarted = new BreakEvent();
    [SerializeField] private UnityEvent onBreakEnded = new UnityEvent();

    public bool IsOnBreak { get; private set; }
    public BreakEvent OnBreakStarted => onBreakStarted;
    public UnityEvent OnBreakEnded => onBreakEnded;

    public void BeginBreak(int distanceMetres)
    {
        if (IsOnBreak) return;
        IsOnBreak = true;
        if (runner != null) runner.SetRunning(false);
        onBreakStarted.Invoke(distanceMetres);
    }

    public void ResumeRun()
    {
        if (!IsOnBreak) return;
        IsOnBreak = false;
        if (runner != null) runner.SetRunning(true);
        onBreakEnded.Invoke();
    }
}
