# AI Photo Studio Workflows

This folder contains ComfyUI workflows for restoring photographs, repairing local damage, creating new scenes, upscaling images, and making short videos.

## Which file should I open?

- Files ending in `.json` are **ComfyUI editor workflows**. Open these in ComfyUI when you want to upload an image, adjust settings, or work with masks and prompts.
- Files ending in `.api.json` are **automation workflows**. They are designed for the PowerShell scripts and ComfyUI's API.
- Where both versions exist, they perform the same main job. Use the editor file for manual work and the API file for automation.

## Everyday restoration workflows

| Workflow | What it does | Goal |
| --- | --- | --- |
| `01 - Photo Restoration - Kontext.json` | Restores an old or faded photo. It can keep the photo black and white or create a natural colour version. | Produce a cleaner photo while keeping the people, clothing, pose, and original composition recognisable. |
| `01 - Photo Restoration - Kontext.api.json` | Automation version of the Kontext restoration workflow. | Run the same general restoration from the PowerShell pipeline. |
| `02 - Photo Restoration - CCSR Only.json` | Cleans and upscales a photo with CCSR. | Improve detail and resolution after restoration, especially on soft or low-resolution images. |
| `02 - Photo Restoration - CCSR Only.api.json` | Automation version of the CCSR workflow. | Run CCSR cleanup and upscale from the pipeline. |
| `02 - Face Restoration - CodeFormer.json` | Repairs faces using CodeFormer. | Improve damaged, blurry, or low-detail faces without changing the rest of the image. |
| `03 - Face Restoration - CodeFormer.api.json` | Automation version of the CodeFormer face-restoration workflow. | Run face restoration from the pipeline. |
| `08 - Face Restoration - GFPGAN.json` | Repairs faces with GFPGAN v1.4. | Provide an alternative to CodeFormer for faces that need a softer, more natural repair. |
| `08 - Face Restoration - GFPGAN.api.json` | Automation version of the GFPGAN face-restoration workflow. | Run GFPGAN as the face-restoration stage in the separate FullRestoreGFPGAN pipeline. |
| `05A - Colour Restoration.json` | Conservatively restores faded colour, colour casts, tone, and saturation without generating new image content. | Improve old colour photographs while preserving faces, clothing, objects, composition, grain, and period character. |
| `05A - Colour Restoration.api.json` | Automation version of the non-generative colour-restoration workflow. | Run safe colour and tonal correction from the scripts without requiring a mask. |
| `05B - Black & White Colourization.json` | Colourizes monochrome photographs with conservative FLUX Kontext settings. | Create historically plausible colour while preserving composition and recognizable faces. |
| `05B - Black & White Colourization.api.json` | Automation version of the B&W colourization workflow. | Run conservative colourization as a separate optional stage. |
| `03 - Basic 4x Upscale.json` | Enlarges an image by four times with an upscaling model. | Create a larger image while retaining as much visible detail as possible. |
| `03 - Basic 4x Upscale.api.json` | Automation version of the 4x upscale workflow. | Run the 4x upscale stage from the pipeline. |

## Damage-repair workflows

| Workflow | What it does | Goal |
| --- | --- | --- |
| `04 - Photo Healing - Kontext.json` | Performs an all-over healing pass for common photo damage such as stains, fading, scratches, and uneven lighting. | Create a generally cleaner, more balanced photograph while keeping people recognisable. |
| `04 - Photo Healing - Kontext.api.json` | Automation version of Photo Healing. | Run a whole-photo healing pass from the pipeline. |
| `06 - Selective Damage Healing - Kontext.json` | Repairs only the part of an image selected by a white mask. The workflow uses the original image everywhere else. | Fix a specific scratch, tear, stain, or damaged edge without changing faces or undamaged areas. |
| `06 - Selective Damage Healing - Kontext.api.json` | API version of selective healing. It needs both the original image and a white-on-black damage mask. | Support direct API use for targeted repairs. |
| `Restoration/04 - Physical Damage Repair - SDXL Local.json` | Uses ComfyUI's Mask Editor, a small local crop, and SDXL inpainting to repair painted damage. It does not need the Fooocus or LaMa downloads. | Repair scratches, cracks, holes, and stains while leaving unmasked pixels untouched. This is the recommended local repair workflow. |
| `Restoration/04 - Physical Damage Repair - SDXL Local.api.json` | API version of the SDXL Local physical-damage workflow. | Automate masked local repairs once a mask is available. |
| `Restoration/04 - Physical Damage Repair - Fooocus Inpaint.json` | Uses the same masked local repair approach, with a LaMa prefill and Fooocus SDXL inpainting refinement. | Provide a higher-quality option for larger missing areas when its extra model files are installed. |
| `Restoration/04 - Physical Damage Repair - Fooocus Inpaint.api.json` | API version of the Fooocus physical-damage workflow. | Automate the Fooocus/LaMa repair process after its required models are installed. |

## Creative editing workflows

| Workflow | What it does | Goal |
| --- | --- | --- |
| `05 - Scene Regeneration - Kontext.json` | Uses the source image as a person and face reference, then follows your prompt to create new backgrounds, clothing, settings, lighting, or mood. | Keep the person recognisable while changing the scene around them. |
| `05 - Scene Regeneration - Kontext.api.json` | Automation version of Scene Regeneration. | Run scene changes through the API after setting the prompt. |
| `Generation/scene-composer-workflow-v1.2.json` | An advanced multi-scene image-generation workflow with scene controls, seeds, batching, previews, and upscaling. | Build several related generated scenes in one larger workflow. |
| `Upscale.json` | Despite its filename, this is an advanced scene-composer style workflow with multiple scene sections and an upscale output. | Generate and combine multiple scenes, then save an upscaled result. |

## Video-generation workflows

| Workflow | What it does | Goal |
| --- | --- | --- |
| `07 - Face Preserving Image To Video - Wan.json` | Turns one source image into a short MP4 video using Wan 2.2. You can set the video length in seconds. | Add subtle movement while trying to keep the face and identity consistent. |
| `07 - Face Preserving Image To Video - Wan.api.json` | API version of the face-preserving Wan video workflow. | Submit an image-to-video job directly to ComfyUI's API. |
| `Generation/video_wan2_2_5B_ti2v - civitai.json` | A detailed Wan 2.2 image-to-video workflow with prompt tools, optional frame interpolation, and video export. | Create higher-control image-to-video clips from a source image. |
| `Generation/Wan22_ImageToVideo_Studio_v1.json` | A studio-style Wan 2.2 image-to-video workflow with manual and scene-composer prompt options. | Create an image-to-video clip with more control over the prompt and scene. |
| `Generation/Wan22-I2V-Remix-V3.json` | A Wan 2.2 Remix image-to-video workflow with model, resolution, prompt, and sampling controls. | Generate a customised image-to-video clip with the Remix model. |
| `Generation/Wan22-I2V-Remix-V3-480p-21f.json` | A lighter 480p, 21-frame version of the Wan 2.2 Remix workflow. | Make faster, lower-resolution test clips before committing to longer or larger videos. |

## Duplicate API copy

- `api/01 - Photo Restoration - Kontext.api.json` is an additional copy of the Kontext API workflow. Its goal is the same as `01 - Photo Restoration - Kontext.api.json`.

## Quick guidance

- For a normal old-photo cleanup, start with **01 - Photo Restoration - Kontext**.
- For a small damaged area, use **06 - Selective Damage Healing** or **Restoration/04 - Physical Damage Repair - SDXL Local**.
- For face-only problems, compare **CodeFormer** and **08 - Face Restoration - GFPGAN** after the main restoration.
- For a new setting or clothing, use **05 - Scene Regeneration**.
- For a short moving clip, use **07 - Face Preserving Image To Video - Wan**.
- Keep the original image. Every workflow can make mistakes, especially around faces, hands, writing, and heavily damaged areas.



