using UnityEngine;
public sealed class RunnerCameraFollow : MonoBehaviour
{
    [SerializeField] Transform target; [SerializeField] Vector3 offset = new Vector3(0f, 5.5f, -9f);
    public void Configure(Transform value) { target = value; }
    void LateUpdate() { if (target == null) return; transform.position = Vector3.Lerp(transform.position, target.position + offset, 7f * Time.deltaTime); transform.LookAt(target.position + new Vector3(0f, 1.1f, 7f)); }
}
