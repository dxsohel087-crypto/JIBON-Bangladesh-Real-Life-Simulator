using UnityEngine;
[RequireComponent(typeof(CharacterController))]
public sealed class RunnerController : MonoBehaviour
{
    [SerializeField] float forwardSpeed = 9f, laneWidth = 2.5f, laneChangeSpeed = 13f, jumpHeight = 2.1f, gravity = -24f, slideDuration = .75f, swipeThreshold = 55f;
    CharacterController controller; int lane = 1; float verticalVelocity, slideTimer, standingHeight; Vector3 standingCenter; Vector2 touchStart; bool trackingTouch, running = true;
    public bool IsRunning => running; public bool IsSliding => slideTimer > 0f;
    void Awake() { controller = GetComponent<CharacterController>(); standingHeight = controller.height; standingCenter = controller.center; }
    void Update()
    {
        if (!running) return;
        ReadInput(); if (slideTimer > 0f && (slideTimer -= Time.deltaTime) <= 0f) RestoreCollider();
        float targetX = (lane - 1) * laneWidth;
        float xSpeed = Mathf.Clamp((targetX - transform.position.x) * laneChangeSpeed, -laneChangeSpeed, laneChangeSpeed);
        if (controller.isGrounded && verticalVelocity < 0f) verticalVelocity = -2f;
        verticalVelocity += gravity * Time.deltaTime;
        controller.Move(new Vector3(xSpeed, verticalVelocity, forwardSpeed) * Time.deltaTime);
    }
    void ReadInput()
    {
        if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A)) ChangeLane(-1);
        if (Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D)) ChangeLane(1);
        if (Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W)) Jump();
        if (Input.GetKeyDown(KeyCode.DownArrow) || Input.GetKeyDown(KeyCode.S)) Slide();
        if (Input.touchCount == 0) { trackingTouch = false; return; }
        Touch t = Input.GetTouch(0);
        if (t.phase == TouchPhase.Began) { touchStart = t.position; trackingTouch = true; }
        else if (trackingTouch && (t.phase == TouchPhase.Ended || t.phase == TouchPhase.Canceled))
        {
            Vector2 d = t.position - touchStart; trackingTouch = false; if (d.magnitude < swipeThreshold) return;
            if (Mathf.Abs(d.x) > Mathf.Abs(d.y)) ChangeLane(d.x > 0 ? 1 : -1); else if (d.y > 0) Jump(); else Slide();
        }
    }
    public void ChangeLane(int direction) { lane = Mathf.Clamp(lane + direction, 0, 2); }
    public void Jump() { if (running && controller.isGrounded && !IsSliding) verticalVelocity = Mathf.Sqrt(jumpHeight * -2f * gravity); }
    public void Slide() { if (!running || !controller.isGrounded) return; slideTimer = slideDuration; controller.height = standingHeight * .55f; controller.center = standingCenter * .55f; }
    void RestoreCollider() { if (controller == null) return; controller.height = standingHeight; controller.center = standingCenter; }
    public void SetRunning(bool value) { running = value; if (!value) { verticalVelocity = 0f; trackingTouch = false; RestoreCollider(); } }
}
