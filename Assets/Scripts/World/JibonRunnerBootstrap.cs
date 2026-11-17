using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using UnityEngine.EventSystems;
using System.Collections.Generic;
public sealed class JibonRunnerBootstrap : MonoBehaviour
{
    RunnerController runner; RunnerGameSession session; DistanceTracker distance; FoodBreakManager breaks; Text hud; GameObject breakPanel, pausePanel, overPanel;
    float hazardAt = 38f, coinAt = 20f, nextRoadZ = 0f; readonly Queue<GameObject> roadPool = new Queue<GameObject>(); Material road, grass, human, hazard, coin, house, lineMat;
    void Start() { Application.targetFrameRate = 60; MakeMaterials(); MakeWorld(); MakePlayer(); MakeCamera(); MakeSystems(); MakeHud(); }
    void Update()
    {
        if (runner == null || !runner.IsRunning || session.IsGameOver) return;
        MaintainEndlessRoad();
        float z = runner.transform.position.z;
        if (z + 85f > hazardAt) { MakeHazard(hazardAt); hazardAt += Random.Range(24f, 35f); }
        if (z + 60f > coinAt) { MakeCoins(coinAt); coinAt += Random.Range(18f, 27f); }
        if (hud != null) hud.text = "দূরত্ব: " + Mathf.FloorToInt(session.Distance) + " মিটার     কয়েন: " + session.Coins;
    }
    Material Mat(Color c) { Material m = new Material(Shader.Find("Standard")); m.color = c; return m; }
    void MakeMaterials() { road=Mat(new Color(.19f,.2f,.21f)); grass=Mat(new Color(.12f,.38f,.16f)); human=Mat(new Color(.08f,.25f,.82f)); hazard=Mat(new Color(.78f,.12f,.07f)); coin=Mat(new Color(1f,.72f,.05f)); house=Mat(new Color(.7f,.58f,.4f)); lineMat=Mat(Color.white); }
    GameObject Cube(string n, Vector3 p, Vector3 s, Material m, bool solid = false) { GameObject g=GameObject.CreatePrimitive(PrimitiveType.Cube); g.name=n; g.transform.position=p; g.transform.localScale=s; g.GetComponent<Renderer>().material=m; if(!solid) g.GetComponent<Collider>().enabled=false; return g; }
    void MakeWorld()
    {
        for (int i=0;i<12;i++) SpawnRoadSegment();
        for(int i=0;i<28;i++) { float z=i*12f+8f; Tree(new Vector3(-9,0,z)); Tree(new Vector3(9,0,z+4)); if(i%4==0) House(new Vector3(i%8==0?-15:15,0,z+2)); }
        
    }
    void MaintainEndlessRoad()
    {
        while (runner.transform.position.z + 240f > nextRoadZ) SpawnRoadSegment();
        while (roadPool.Count > 12)
        {
            GameObject old = roadPool.Peek();
            if (old == null) { roadPool.Dequeue(); continue; }
            if (old.transform.position.z + 30f > runner.transform.position.z - 60f) break;
            roadPool.Dequeue(); Destroy(old);
        }
    }
    void SpawnRoadSegment()
    {
        GameObject segment = new GameObject("Endless road segment");
        segment.transform.position = new Vector3(0f,0f,nextRoadZ);
        roadPool.Enqueue(segment);
        GameObject slab = GameObject.CreatePrimitive(PrimitiveType.Cube); slab.name="Road surface"; slab.transform.SetParent(segment.transform,false); slab.transform.localPosition=new Vector3(0f,-.2f,15f); slab.transform.localScale=new Vector3(9f,.4f,30f); slab.GetComponent<Renderer>().material=road;
        for(int side=-1;side<=1;side+=2) { GameObject field=GameObject.CreatePrimitive(PrimitiveType.Cube); field.transform.SetParent(segment.transform,false); field.transform.localPosition=new Vector3(side*24f,-.48f,15f); field.transform.localScale=new Vector3(38f,.2f,30f); field.GetComponent<Renderer>().material=grass; field.GetComponent<Collider>().enabled=false; }
        for(int i=0;i<2;i++) { GameObject mark=GameObject.CreatePrimitive(PrimitiveType.Cube); mark.transform.SetParent(segment.transform,false); mark.transform.localPosition=new Vector3(i==0?-1.25f:1.25f,.015f,Random.Range(4f,26f)); mark.transform.localScale=new Vector3(.08f,.025f,2f); mark.GetComponent<Renderer>().material=lineMat; mark.GetComponent<Collider>().enabled=false; }
        for(int side=-1;side<=1;side+=2) if(Random.value>.18f) Tree(new Vector3(side*Random.Range(8f,13f),0f,nextRoadZ+Random.Range(3f,27f)),segment.transform);
        if(Random.value>.72f) House(new Vector3(Random.value>.5f?-15f:15f,0f,nextRoadZ+15f),segment.transform);
        nextRoadZ += 30f;
    }
    void Tree(Vector3 p, Transform parent = null) { GameObject t=GameObject.CreatePrimitive(PrimitiveType.Cylinder); t.transform.position=p+Vector3.up*1.2f; t.transform.localScale=new Vector3(.35f,1.2f,.35f); t.GetComponent<Renderer>().material=house; t.GetComponent<Collider>().enabled=false; if(parent!=null)t.transform.SetParent(parent,true); GameObject c=GameObject.CreatePrimitive(PrimitiveType.Sphere); c.transform.position=p+Vector3.up*3f; c.transform.localScale=Vector3.one*2.5f; c.GetComponent<Renderer>().material=grass; c.GetComponent<Collider>().enabled=false; }
    void House(Vector3 p) { Cube("Village house",p+Vector3.up*1.1f,new Vector3(4,2.2f,5),house); Cube("Tin roof",p+Vector3.up*2.35f,new Vector3(4.5f,.35f,5.5f),hazard); }
    void MakePlayer() { GameObject p=GameObject.CreatePrimitive(PrimitiveType.Capsule); p.name="Player"; p.transform.position=new Vector3(0,1,4); Destroy(p.GetComponent<CapsuleCollider>()); CharacterController cc=p.AddComponent<CharacterController>(); cc.height=1.8f; cc.radius=.42f; cc.center=new Vector3(0,.9f,0); p.GetComponent<Renderer>().material=human; runner=p.AddComponent<RunnerController>(); }
    void MakeCamera() { GameObject g=new GameObject("Runner Camera"); Camera c=g.AddComponent<Camera>(); c.fieldOfView=68; g.AddComponent<AudioListener>(); g.transform.position=runner.transform.position+new Vector3(0,5.5f,-9); g.AddComponent<RunnerCameraFollow>().Configure(runner.transform); RenderSettings.ambientLight=new Color(.6f,.64f,.7f); GameObject l=new GameObject("Sun"); l.AddComponent<Light>().type=LightType.Directional; l.transform.rotation=Quaternion.Euler(48,-30,0); }
    void MakeSystems() { GameObject g=new GameObject("Game Systems"); distance=g.AddComponent<DistanceTracker>(); distance.Configure(runner.transform); breaks=g.AddComponent<FoodBreakManager>(); breaks.Configure(runner); session=g.AddComponent<RunnerGameSession>(); session.Configure(runner,distance,breaks); breaks.OnBreakStarted.AddListener(_=>breakPanel.SetActive(true)); session.OnGameOver.AddListener(_=>{overPanel.SetActive(true);}); }
    Text TextUI(Transform parent,string value,int size,Vector2 min,Vector2 max) { GameObject g=new GameObject("Text"); g.transform.SetParent(parent,false); Text t=g.AddComponent<Text>(); t.font=Resources.GetBuiltinResource<Font>("Arial.ttf"); t.text=value; t.fontSize=size; t.color=Color.white; t.alignment=TextAnchor.MiddleCenter; RectTransform r=t.rectTransform; r.anchorMin=min; r.anchorMax=max; r.offsetMin=Vector2.zero; r.offsetMax=Vector2.zero; return t; }
    void ButtonUI(Transform parent,string label,Vector2 pos,UnityEngine.Events.UnityAction action) { GameObject g=new GameObject(label); g.transform.SetParent(parent,false); Image im=g.AddComponent<Image>(); im.color=new Color(.06f,.4f,.18f,.95f); Button b=g.AddComponent<Button>(); b.onClick.AddListener(action); RectTransform r=g.GetComponent<RectTransform>(); r.anchorMin=pos-new Vector2(.09f,.04f); r.anchorMax=pos+new Vector2(.09f,.04f); r.offsetMin=Vector2.zero; r.offsetMax=Vector2.zero; TextUI(g.transform,label,20,Vector2.zero,Vector2.one); }
    GameObject Panel(Transform parent,string title,string button,UnityEngine.Events.UnityAction action) { GameObject g=new GameObject(title); g.transform.SetParent(parent,false); g.AddComponent<Image>().color=new Color(0,0,0,.84f); RectTransform r=g.GetComponent<RectTransform>(); r.anchorMin=new Vector2(.15f,.28f); r.anchorMax=new Vector2(.85f,.72f); r.offsetMin=Vector2.zero; r.offsetMax=Vector2.zero; TextUI(g.transform,title,32,new Vector2(.05f,.55f),new Vector2(.95f,.9f)); ButtonUI(g.transform,button,new Vector2(.5f,.25f),action); return g; }
    void MakeHud() { GameObject g=new GameObject("JIBON HUD"); Canvas c=g.AddComponent<Canvas>(); c.renderMode=RenderMode.ScreenSpaceOverlay; g.AddComponent<CanvasScaler>().uiScaleMode=CanvasScaler.ScaleMode.ScaleWithScreenSize; g.AddComponent<GraphicRaycaster>(); GameObject es=new GameObject("EventSystem"); es.AddComponent<EventSystem>(); es.AddComponent<StandaloneInputModule>(); hud=TextUI(g.transform,"দূরত্ব: 0 মিটার",22,new Vector2(.02f,.91f),new Vector2(.7f,.99f)); ButtonUI(g.transform,"বিরতি",new Vector2(.9f,.95f),Pause); breakPanel=Panel(g.transform,"খাবারের বিরতি","আবার দৌড় শুরু",ResumeBreak); pausePanel=Panel(g.transform,"খেলা বিরতি","চালু করুন",Resume); overPanel=Panel(g.transform,"খেলা শেষ","আবার খেলুন",Restart); breakPanel.SetActive(false); pausePanel.SetActive(false); overPanel.SetActive(false); }
    void MakeHazard(float z) { int lane=Random.Range(0,3); GameObject o=Cube("Obstacle vehicle",new Vector3((lane-1)*2.5f,.85f,z),new Vector3(1.8f,1.7f,2.4f),hazard,true); o.AddComponent<RunnerObstacle>(); }
    void MakeCoins(float z) { int lane=Random.Range(0,3); for(int i=0;i<5;i++){ GameObject o=GameObject.CreatePrimitive(PrimitiveType.Cylinder); o.name="Coin"; o.transform.position=new Vector3((lane-1)*2.5f,1.15f,z+i*1.5f); o.transform.localScale=new Vector3(.45f,.08f,.45f); o.GetComponent<Renderer>().material=coin; Collider c=o.GetComponent<Collider>(); c.isTrigger=true; Rigidbody rb=o.AddComponent<Rigidbody>(); rb.isKinematic=true; o.AddComponent<RunnerCollectible>(); } }
    void Pause() { runner.SetRunning(false); Time.timeScale=0; pausePanel.SetActive(true); }
    void Resume() { pausePanel.SetActive(false); Time.timeScale=1; runner.SetRunning(true); }
    void ResumeBreak() { breakPanel.SetActive(false); breaks.ResumeRun(); }
    void Restart() { Time.timeScale=1; SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex); }
}
