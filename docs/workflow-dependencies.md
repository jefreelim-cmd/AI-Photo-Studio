\# Workflow Dependencies



\## Workflow 01 - Basic 4x Upscale



Models



\- 4x-UltraSharp



Extensions



\- Built-in ComfyUI



\---



\## Workflow 02 - Face Restoration



Models



\- CodeFormer



Extensions



\- FaceRestore CF



\---



\## Workflow 03 - Whole Image Restoration



Models



\- SDXL Base

\- SDXL VAE

\- CLIP-G

\- CLIP-L

\- SUPIR-v0F

\- SUPIR-v0Q



Extensions



\- ComfyUI-SUPIR





\## Workflow 04 - CCSR + SUPIR Ultimate Restoration



Status



In Evaluation



Purpose



Whole-image restoration using CCSR followed by SUPIR refinement.



Source



Workflow:

https://github.com/FurkanGozukara/Stable-Diffusion



Workflow JSON:

supir\_lightning\_example\_02.json



\---



Required Custom Nodes



\- ComfyUI-SUPIR

\- comfyui-ccsr

\- ComfyUI-Crystools

\- promptmodels

\- rgthree-comfy (manual GitHub installation)

\- Comfyroll Custom Nodes



\---



Required Models



CCSR



\- real-world\_ccsr-fp32.safetensors

\- real-world\_ccsr-fp16.safetensors



SUPIR



\- SUPIR-v0F\_fp16.safetensors

\- SUPIR-v0Q\_fp16.safetensors



SDXL



\- sd\_xl\_base\_1.0.safetensors



Text Encoders



\- clip\_g.safetensors

\- clip\_l.safetensors



\---



Workflow Modifications



\- Installed missing custom nodes.

\- Installed rgthree-comfy manually from GitHub.

\- Downloaded CCSR models.

\- Replaced CCSR\_Model\_Select with DownloadAndLoadCCSRModel.

\- Updated Image Resize node method from "false" to "keep proportion".

\- Patched comfyui-ccsr Python files for compatibility with current ComfyUI.

\- Workflow now executes successfully.



\---



Known Issues



\- SUPIR stage remains extremely slow on RTX 4070 Laptop GPU.

\- Original SUPIR Lightning workflow produced minimal quality improvement.

\- Further benchmarking required.



\---



Benchmark Status



Status:

In Progress



Benchmark Image:

Family school photograph (1536 × 1104)



Current Result:

CCSR workflow under evaluation.

