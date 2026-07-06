\# AI Photo Studio - Model Registry



This document records every AI model used by AI Photo Studio.



The purpose is to:



\- rebuild the environment from scratch

\- understand why each model exists

\- avoid duplicate downloads

\- know which workflows depend on each model



\---



\# Foundation Models



| Model | Version | Location | Purpose | Used By | Status |

|--------|---------|----------|----------|---------|--------|

| sd\_xl\_base\_1.0.safetensors | SDXL 1.0 | checkpoints/SDXL | Base diffusion model for SUPIR | Workflow 03+ | ✅ Installed |

| sdxl\_vae.safetensors | SDXL VAE | vae/SDXL | Official SDXL VAE | Workflow 03+ | ✅ Installed |

| clip\_g.safetensors | SDXL CLIP-G | text\_encoders | Text encoder | Workflow 03+ | ✅ Installed |

| clip\_l.safetensors | SDXL CLIP-L | text\_encoders | Text encoder | Workflow 03+ | ✅ Installed |



\---



\# Restoration Models



| Model | Version | Location | Purpose | Used By | Status |

|--------|---------|----------|----------|---------|--------|

| codeformer.pth | CodeFormer | facerestore\_models | Face restoration | Workflow 02+ | ✅ Installed |

| SUPIR-v0F\_fp16.safetensors | v0F | checkpoints/SUPIR | High fidelity restoration | Workflow 03+ | ✅ Installed |

| SUPIR-v0Q\_fp16.safetensors | v0Q | checkpoints/SUPIR | Heavy damage restoration | Workflow 03+ | ✅ Installed |

| 4x-UltraSharp.pth | ESRGAN | upscale\_models | Final image upscaling | Workflow 01+ | ✅ Installed |



\---



\# Future Models



| Model | Purpose | Status |

|---------|---------|--------|

| None | - | - |



\---



\# Retirement Log



Record removed models here.



| Model | Reason Removed | Date |

|---------|----------------|------|

| None | - | - |

