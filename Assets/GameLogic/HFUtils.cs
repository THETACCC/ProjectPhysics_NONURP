using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


namespace HFUtils
{
    public class HFUtils : MonoBehaviour
    {
        public static HFUtils instance;
        public static Camera mainCam;

        void Awake()
        {
            if (instance == null)
            {
                instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else
            {
                Destroy(gameObject);
            }
            
        }

        private void Start()
        {
            mainCam = Camera.main;
            Debug.Log(mainCam.name);
        }

        public void LoadNextScene()
        {
            int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
            int nextSceneIndex = currentSceneIndex + 1;

            if (nextSceneIndex < SceneManager.sceneCountInBuildSettings)
            {

                SceneManager.LoadSceneAsync(nextSceneIndex);
            }
            else
            {
                Debug.LogWarning(" No scene loaded.");
            }
        }


    }
}

