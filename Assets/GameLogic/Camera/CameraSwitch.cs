using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraSwitch : MonoBehaviour
{
    [SerializeField] CinemachineVirtualCamera firstPersonCam;
    [SerializeField] CinemachineVirtualCamera thirdPersonCam;

    private void OnEnable()
    {
        CameraSwitcher.Register(thirdPersonCam);
        CameraSwitcher.Register(firstPersonCam);
        CameraSwitcher.SwitchCamera(firstPersonCam);
    }

    private void OnDisable ()
    {
        CameraSwitcher.UnRegister(thirdPersonCam);
        CameraSwitcher.UnRegister(firstPersonCam);
    }
    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.K))
        {
            //switch camera
            if(CameraSwitcher.isActiveCamera(thirdPersonCam))
            {
                CameraSwitcher.SwitchCamera(firstPersonCam);
            }
            else if(CameraSwitcher.isActiveCamera(firstPersonCam))
            {
                Debug.Log("Switch to thrid person");
                CameraSwitcher.SwitchCamera(thirdPersonCam);
            }
        }
    }
}
