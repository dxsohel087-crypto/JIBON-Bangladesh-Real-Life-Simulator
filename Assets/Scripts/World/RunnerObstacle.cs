using UnityEngine;
public sealed class RunnerObstacle : MonoBehaviour
{
    void OnControllerColliderHit(ControllerColliderHit hit) { RunnerGameSession s = FindObjectOfType<RunnerGameSession>(); if (s != null) s.HitObstacle(); }
}
