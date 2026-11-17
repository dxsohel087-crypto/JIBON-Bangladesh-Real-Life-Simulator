using UnityEngine;
public sealed class RunnerCollectible : MonoBehaviour
{
    [SerializeField] int coinValue = 1;
    void Update() { transform.Rotate(0f, 110f * Time.deltaTime, 0f, Space.World); }
    void OnTriggerEnter(Collider other) { RunnerGameSession s = FindObjectOfType<RunnerGameSession>(); if (s == null) return; s.AddCoin(coinValue); Destroy(gameObject); }
}
