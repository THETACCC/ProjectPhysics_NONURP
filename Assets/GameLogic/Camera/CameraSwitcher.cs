using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraSwitcher 
{
        static List<CinemachineVirtualCamera> _cameras = new List<CinemachineVirtualCamera>();


    public static CinemachineVirtualCamera activeCamera = null;


    public static bool isActiveCamera(CinemachineVirtualCamera camera)
    {
        return camera == activeCamera;
    }

    public static void SwitchCamera(CinemachineVirtualCamera camera)
    {
        camera.Priority = 20;
        activeCamera = camera;
        Debug.Log(activeCamera);
        foreach (CinemachineVirtualCamera cam in _cameras)
        {
            if(cam != camera && cam.Priority != 10)
            {
                cam.Priority = 10;
            }
        }
    }

    public static void Register(CinemachineVirtualCamera camera)
    {
        _cameras.Add(camera);
    }

    public static void UnRegister(CinemachineVirtualCamera camera)
    {
        _cameras.Remove(camera);
    }
}
