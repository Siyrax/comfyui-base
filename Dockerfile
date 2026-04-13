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
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && pip install -r requirements.txt

# Clone ALL custom nodes
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper && \
    git clone https://github.com/kijai/ComfyUI-WanAnimatePreprocess && \
    git clone https://github.com/Lightricks/ComfyUI-LTXVideo && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    git clone https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler && \
    git clone https://github.com/kijai/ComfyUI-KJNodes && \
    git clone https://github.com/city96/ComfyUI-GGUF && \
    git clone https://github.com/calcuis/gguf && \
    git clone https://github.com/kijai/ComfyUI-segment-anything-2 && \
    git clone https://github.com/kijai/ComfyUI-Florence2 && \
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
    git clone https://github.com/rgthree/rgthree-comfy && \
    git clone https://github.com/sipherxyz/comfyui-art-venture && \
    git clone https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait && \
    git clone https://github.com/1038lab/ComfyUI-JoyCaption && \
    git clone https://github.com/judian17/ComfyUI-PixelSmile-Conditioning-Interpolation && \
    git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes && \
    git clone https://github.com/WASasquatch/was-node-suite-comfyui && \
    git clone https://github.com/ChangeTheConstants/SeedVarianceEnhancer && \
    git clone https://github.com/gseth/ControlAltAI-Nodes && \
    git clone https://github.com/yolain/ComfyUI-Easy-Use && \
    git clone https://github.com/vrgamegirl19/comfyui-vrgamedevgirl && \
    git clone https://github.com/moonwhaler/comfyui-moonpack && \
    git clone https://github.com/M1kep/ComfyLiterals

# Install all custom node requirements
RUN for dir in /ComfyUI/custom_nodes/*/; do \
      if [ -f "$dir/requirements.txt" ]; then \
        echo "Installing deps for $(basename $dir)..." && \
        pip install -r "$dir/requirements.txt" || true; \
      fi; \
    done
