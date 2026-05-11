# ComfyUI base image with all custom nodes pre-installed.
# No models, no handlers, no workflows — just the engine + nodes + deps.
# Use as a base image for serverless endpoints.
#
# Models are expected on a mounted volume via extra_model_paths.yaml.

FROM wlsdml1114/multitalk-base:1.7

ENV PIP_NO_CACHE_DIR=1
ENV AUX_ANNOTATOR_CKPTS_PATH=/ComfyUI/custom_nodes/comfyui_controlnet_aux/ckpts

# Core pip deps
RUN pip install -U pip setuptools wheel && \
    pip install runpod websocket-client "huggingface_hub[hf_transfer]" && \
    pip install Cython && pip install insightface && \
    pip install onnxruntime-gpu || pip install onnxruntime

WORKDIR /

# Fresh ComfyUI
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && pip install -r requirements.txt

# Clone all custom nodes required by the 11 production workflows.
# Removed 2026-05-11 (audited unused across all workflows):
#   - PowerHouseMan/ComfyUI-AdvancedLivePortrait  (~300 MB, mediapipe)
#   - WASasquatch/was-node-suite-comfyui          (~800 MB, transformers+git deps)
#   - M1kep/ComfyLiterals                         (no requirements.txt; literals)
#   - chflame163/ComfyUI_LayerStyle               (~1 GB, PIL plugins + seg models)
#   - 1038lab/ComfyUI-QwenVL                      (TextEncodeQwenImageEditPlus is core)
RUN cd /ComfyUI/custom_nodes && \
    git clone --depth 1 https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-WanVideoWrapper && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-WanAnimatePreprocess && \
    git clone --depth 1 https://github.com/Lightricks/ComfyUI-LTXVideo && \
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    git clone --depth 1 https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes && \
    git clone --depth 1 https://github.com/city96/ComfyUI-GGUF && \
    git clone --depth 1 https://github.com/calcuis/gguf && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-segment-anything-2 && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-Florence2 && \
    git clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux && \
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Pack && \
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy && \
    git clone --depth 1 https://github.com/sipherxyz/comfyui-art-venture && \
    git clone --depth 1 https://github.com/1038lab/ComfyUI-JoyCaption && \
    git clone --depth 1 https://github.com/judian17/ComfyUI-PixelSmile-Conditioning-Interpolation && \
    git clone --depth 1 https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes && \
    git clone --depth 1 https://github.com/ChangeTheConstants/SeedVarianceEnhancer && \
    git clone --depth 1 https://github.com/gseth/ControlAltAI-Nodes && \
    git clone --depth 1 https://github.com/yolain/ComfyUI-Easy-Use && \
    git clone --depth 1 https://github.com/vrgamegirl19/comfyui-vrgamedevgirl && \
    git clone --depth 1 https://github.com/moonwhaler/comfyui-moonpack && \
    git clone --depth 1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts && \
    git clone --depth 1 https://github.com/ClownsharkBatwing/RES4LYF

# Install all custom node requirements
RUN for dir in /ComfyUI/custom_nodes/*/; do \
      if [ -f "$dir/requirements.txt" ]; then \
        echo "Installing deps for $(basename $dir)..." && \
        pip install -r "$dir/requirements.txt" || true; \
      fi; \
    done

# Strip git history and bytecode caches we just created
RUN find /ComfyUI/custom_nodes -type d -name .git -exec rm -rf {} + 2>/dev/null || true && \
    find /ComfyUI -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true && \
    find /ComfyUI -type f -name "*.pyc" -delete 2>/dev/null || true
