using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;
using UnityEngine;

public class PixelEffectPlayer : MonoBehaviour {

    [SerializeField]
    private bool UIType = false;

    [SerializeField, Range(0.1f, 10f)]
    private float Duration = 2f;

    [SerializeField]
    private AnimationCurve Curve;

    private MaterialPropertyBlock block;

    private Renderer s_renderer;

    private Material uiMaterial;

    private MaskableGraphic uiElement;

    private int thresholdID = 0;

    private IEnumerator runAnimation;

    public void Show(Action Callback = null) {
        if(runAnimation != null)
            StopCoroutine(runAnimation);

        runAnimation = RunAnimation(true, Callback);

        StartCoroutine(runAnimation);
    }

    public void Hide(Action Callback = null) {
        if(runAnimation != null)
            StopCoroutine(runAnimation);

        runAnimation = RunAnimation(false, Callback);

        StartCoroutine(runAnimation);
    }

    private void Update() {
        if(Input.GetKeyDown(KeyCode.A)) {
            Show(() => {
                Debug.Log("show completed");
            });
        }

        if(Input.GetKeyDown(KeyCode.D)) {
            Hide(() => {
                Debug.Log("hide completed");
            });
        }
    }

    private void Start() {
        thresholdID = Shader.PropertyToID("_Threshold");

        if(UIType) {
            uiElement = GetComponent<MaskableGraphic>();

            uiMaterial = Instantiate(uiElement.material);

            uiElement.material = uiMaterial;
        } else {
            s_renderer = GetComponent<Renderer>();

            block = new MaterialPropertyBlock();

            s_renderer.GetPropertyBlock(block);
        }
    }

    private IEnumerator RunAnimation(bool RunShow, Action Callback) {

        var timeCache = 0f;

        var startValue = RunShow ? -0.1f : 1.2f;

        var targetValue = RunShow ? 1.2f : -0.1f;

        while(timeCache <= Duration) {

            timeCache += Time.deltaTime;

            var v = Mathf.Lerp(startValue, targetValue, Curve.Evaluate(Mathf.Clamp01(timeCache / Duration)));

            if(UIType) {
                uiMaterial.SetFloat(thresholdID, v);
            } else {
                block.SetFloat(thresholdID, v);

                s_renderer.SetPropertyBlock(block);
            }

            yield return null;
        }

        if(Callback != null)
            Callback();
    }
}
