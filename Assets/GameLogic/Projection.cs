using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Pool;
using UnityEngine.SceneManagement;


public class Projection : MonoBehaviour
{
    [SerializeField] private Transform _obstaclesParent;
    [SerializeField] private int _maxPhysicsFrameIterations = 100;
    [SerializeField] private LineRenderer _line;
    public Bullet ghostObj;
    private ObjectPool<Bullet> bulletPool;
    private Scene _simulationScene;
    private PhysicsScene _physicsScene;
    private readonly Dictionary<Transform, Transform> _spawnedObjects = new Dictionary<Transform, Transform>();
    private void Start()
    {

        //CreatePhysicsScene();
        
        bulletPool = new ObjectPool<Bullet>(() =>
        {
            var bullet = Instantiate(ghostObj);
            bullet.gameObject.SetActive(false); // Initially inactive
            SceneManager.MoveGameObjectToScene(bullet.gameObject, _simulationScene);
            return bullet;
        }, bullet =>
        {
            bullet.gameObject.SetActive(true);
        }, bullet =>
        {
            bullet.gameObject.SetActive(false);
        }, bullet =>
        {
            Destroy(bullet.gameObject);
        }, true, 15, 20);
        


        //for (int i = 0; i < 15; i++)
        //{
            //var ghostObj2 = bulletPool.Get();
            //SceneManager.MoveGameObjectToScene(ghostObj2.gameObject, _simulationScene);
            //bulletPool.Release(ghostObj2);
        //}
    }
    private void CreatePhysicsScene()
    {
        _simulationScene = SceneManager.CreateScene("Simulation", new CreateSceneParameters(LocalPhysicsMode.Physics3D));
        _physicsScene = _simulationScene.GetPhysicsScene();

        foreach (Transform obj in _obstaclesParent)
        {
            var ghostObj = Instantiate(obj.gameObject, obj.position, obj.rotation);
            ghostObj.GetComponent<Renderer>().enabled = false;
            SceneManager.MoveGameObjectToScene(ghostObj, _simulationScene);
            if (!ghostObj.isStatic) _spawnedObjects.Add(obj, ghostObj.transform);
        }
    }
    private void Update()
    {
        foreach (var item in _spawnedObjects)
        {
            item.Value.position = item.Key.position;
            item.Value.rotation = item.Key.rotation;
        }
    }

    public void SimulateTrajectory(Bullet bulletPrefab, Vector3 pos, Vector3 velocity)
    {
        var ghostObj = Instantiate(bulletPrefab, pos, Quaternion.identity);
        //var ghostObj = bulletPool.Get(); // This should activate the object via OnGet
        //ghostObj.transform.position = pos;
        //ghostObj.transform.rotation = Quaternion.identity;
       SceneManager.MoveGameObjectToScene(ghostObj.gameObject, _simulationScene);

        ghostObj.Init(velocity, true); // Initialize bullet with the given velocity

        _line.positionCount = _maxPhysicsFrameIterations;

        for (var i = 0; i < _maxPhysicsFrameIterations; i++)
        {
            _physicsScene.Simulate(Time.fixedDeltaTime);
            _line.SetPosition(i, ghostObj.transform.position); // Update line renderer
        }

        //bulletPool.Release(ghostObj);
        Destroy(ghostObj.gameObject);
    }

    //public void Release()
    //{
    //    
    //}

    public void Initialize(Bullet bulletPrefab, Vector3 pos, Vector3 velocity)
    {
        ghostObj = Instantiate(bulletPrefab, pos, Quaternion.identity);
        SceneManager.MoveGameObjectToScene(ghostObj.gameObject, _simulationScene);
        ghostObj.Init(velocity, true);

        _line.positionCount = _maxPhysicsFrameIterations;

        for (var i = 0; i < _maxPhysicsFrameIterations; i++)
        {
            _physicsScene.Simulate(Time.fixedDeltaTime);
            _line.SetPosition(i, ghostObj.transform.position);
        }

        ghostObj.transform.position = pos;
    }


}
