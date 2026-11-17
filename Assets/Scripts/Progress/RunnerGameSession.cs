using UnityEngine;
using UnityEngine.Events;
public sealed class RunnerGameSession : MonoBehaviour
{
    [System.Serializable] public class IntEvent : UnityEvent<int> { }
    [SerializeField] RunnerController runner; [SerializeField] DistanceTracker tracker; [SerializeField] FoodBreakManager breaks; [SerializeField] IntEvent onCoinsChanged = new IntEvent(); [SerializeField] IntEvent onGameOver = new IntEvent();
    int coins; bool gameOver; public int Coins => coins; public bool IsGameOver => gameOver; public float Distance => tracker != null ? tracker.DistanceMetres : 0f; public IntEvent OnGameOver => onGameOver;
    public void Configure(RunnerController p, DistanceTracker d, FoodBreakManager f) { runner = p; tracker = d; breaks = f; }
    void Start() { if (tracker != null) tracker.OnMilestone.AddListener(OnMilestone); }
    void OnDestroy() { if (tracker != null) tracker.OnMilestone.RemoveListener(OnMilestone); }
    void OnMilestone(int metres) { if (breaks != null) breaks.BeginBreak(metres); }
    public void AddCoin(int amount = 1) { if (gameOver) return; coins += Mathf.Max(0, amount); onCoinsChanged.Invoke(coins); }
    public void HitObstacle() { if (gameOver) return; gameOver = true; if (runner != null) runner.SetRunning(false); int score = Mathf.RoundToInt(Distance); int best = Mathf.Max(PlayerPrefs.GetInt("JibonBestDistance", 0), score); PlayerPrefs.SetInt("JibonBestDistance", best); PlayerPrefs.Save(); onGameOver.Invoke(score); }
}
