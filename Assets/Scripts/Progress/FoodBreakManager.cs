using UnityEngine;
using UnityEngine.Events;
public sealed class FoodBreakManager : MonoBehaviour
{
    [System.Serializable] public class BreakEvent : UnityEvent<int> { }
    [SerializeField] RunnerController runner; [SerializeField] BreakEvent onBreakStarted = new BreakEvent(); [SerializeField] UnityEvent onBreakEnded = new UnityEvent();
    float previousTimeScale = 1f; public bool IsOnBreak { get; private set; } public BreakEvent OnBreakStarted => onBreakStarted; public UnityEvent OnBreakEnded => onBreakEnded;
    public void Configure(RunnerController value) { runner = value; }
    public void BeginBreak(int metres) { if (IsOnBreak) return; IsOnBreak = true; previousTimeScale = Time.timeScale; if (runner != null) runner.SetRunning(false); Time.timeScale = 0f; onBreakStarted.Invoke(metres); }
    public void ResumeRun() { if (!IsOnBreak) return; Time.timeScale = previousTimeScale > 0f ? previousTimeScale : 1f; if (runner != null) runner.SetRunning(true); IsOnBreak = false; onBreakEnded.Invoke(); }
    void OnDestroy() { if (IsOnBreak) Time.timeScale = previousTimeScale > 0f ? previousTimeScale : 1f; }
}
