using UnityEngine;

/// <summary>
/// Three-lane endless-runner movement. Attach to a GameObject with a CharacterController.
/// Animator parameters can be connected later when the final character asset is selected.
/// </summary>
[RequireComponent(typeof(CharacterController))]
public sealed class RunnerController : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] private float forwardSpeed = 8f;
    [SerializeField] private float laneWidth = 2.4f;
    [SerializeField] private float laneChangeSpeed = 12f;
    [SerializeField] private float jumpHeight = 2.2f;
    [SerializeField] private float gravity = -22f;
    [SerializeField] private float slideDuration = 0.8f;
    [SerializeField] private float swipeThreshold = 55f;

    private CharacterController controller;
    private int lane = 1; // 0 = left, 1 = centre, 2 = right
    private float verticalVelocity;
    private float slideTimer;
    private Vector2 touchStart;
    private bool touchTracking;
    private bool inputEnabled = true;

    public float ForwardSpeed => forwardSpeed;
    public bool IsSliding => slideTimer > 0f;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
    }

    private void Update()
    {
        if (!inputEnabled) return;

        ReadInput();
        UpdateSlide();

        float targetX = (lane - 1) * laneWidth;
        float xDelta = (targetX - transform.position.x) * laneChangeSpeed;

        if (controller.isGrounded && verticalVelocity < 0f)
            verticalVelocity = -2f;

        verticalVelocity += gravity * Time.deltaTime;
        Vector3 motion = new Vector3(xDelta, verticalVelocity, forwardSpeed);
        controller.Move(motion * Time.deltaTime);
    }

    private void ReadInput()
    {
        if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A)) ChangeLane(-1);
        if (Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D)) ChangeLane(1);
        if (Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W)) Jump();
        if (Input.GetKeyDown(KeyCode.DownArrow) || Input.GetKeyDown(KeyCode.S)) Slide();

        if (Input.touchCount == 0)
        {
            touchTracking = false;
            return;
        }

        Touch touch = Input.GetTouch(0);
        if (touch.phase == TouchPhase.Began)
        {
            touchStart = touch.position;
            touchTracking = true;
        }
        else if (touchTracking && (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled))
        {
            Vector2 delta = touch.position - touchStart;
            touchTracking = false;
            if (delta.magnitude < swipeThreshold) return;

            if (Mathf.Abs(delta.x) > Mathf.Abs(delta.y))
                ChangeLane(delta.x > 0 ? 1 : -1);
            else if (delta.y > 0)
                Jump();
            else
                Slide();
        }
    }

    public void ChangeLane(int direction)
    {
        lane = Mathf.Clamp(lane + direction, 0, 2);
    }

    public void Jump()
    {
        if (controller.isGrounded && !IsSliding)
            verticalVelocity = Mathf.Sqrt(jumpHeight * -2f * gravity);
    }

    public void Slide()
    {
        if (controller.isGrounded)
            slideTimer = slideDuration;
    }

    private void UpdateSlide()
    {
        if (slideTimer > 0f)
            slideTimer -= Time.deltaTime;
    }

    public void SetRunning(bool running)
    {
        inputEnabled = running;
        if (!running) verticalVelocity = 0f;
    }

    public void SetForwardSpeed(float speed)
    {
        forwardSpeed = Mathf.Max(0f, speed);
    }
}
