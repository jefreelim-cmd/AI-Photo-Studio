\# Design Principles



These principles govern every workflow built for this project.



\---



\## Principle 1 - Preserve Identity



The highest priority is preserving the identity of every person.



The workflow must never intentionally change:



\- facial structure

\- age

\- ethnicity

\- expression

\- hairstyle

\- attractiveness



If preserving identity conflicts with improving detail, identity always wins.



Automation Architecture

Guiding Principles



The automation layer is responsible for orchestrating ComfyUI workflows. It must remain modular, configurable, reusable, and independent of individual workflows.



Configuration First



All configurable values must be stored in a single configuration file (Config.psd1).



PowerShell scripts must contain application logic only and must never contain hardcoded values such as:



Folder paths

URLs

Workflow names

Workflow filenames

Output filenames

Polling intervals

Timeouts

Retry counts

Supported file extensions



Changing system behaviour should require modifying the configuration file only.



Separation of Code and Runtime



Source code and runtime data must remain separate.



Repository (GitHub)



The GitHub repository contains:



PowerShell scripts

Workflow JSON files

Documentation

Tests

Examples

Configuration



Location:



D:\\AI-Photo-Studio\\AI-Photo-Studio



Everything inside this folder is version controlled.



ComfyUI Runtime



The ComfyUI installation contains runtime assets only.



Examples include:



input images

output images

temporary files

logs

models

custom nodes



Location:



D:\\AI-Photo-Studio\\ComfyUI



No source code should reside inside the ComfyUI installation.



Modular Workflow Design



Each ComfyUI workflow must perform one well-defined task.



Examples include:



Photo Restoration

Damage Reconstruction

Face Restoration

Image Upscaling



Workflows should never attempt to solve multiple unrelated problems.



Pipeline Architecture



Complex image restoration is achieved by chaining simple workflows together.



Example:



Original

&#x20;   ↓

Photo Restoration

&#x20;   ↓

Damage Reconstruction

&#x20;   ↓

CCSR

&#x20;   ↓

Upscale

&#x20;   ↓

Final Image



Pipelines must be configurable without changing application code.



Generic Batch Processing



The automation layer must not be coupled to a specific workflow.



The batch runner should be capable of executing any configured workflow.



Future workflows should be usable without modifying the automation code.



Workflow Registry



All workflows must be defined in the configuration file.



Each workflow should define:



Display Name

Workflow JSON filename

Output filename prefix

Enabled/Disabled state



Scripts should reference workflows by logical name rather than filename.



Pipeline Registry



Pipelines should also be defined in the configuration file.



A pipeline consists of an ordered list of workflows.



Example:



Restore



↓



Photo Restoration



or



Full Restore



↓



Photo Restoration



↓



Damage Reconstruction



↓



CCSR



↓



Upscale



Changing a pipeline should never require modifying PowerShell code.



Output Naming Standard



Output filenames must follow a consistent format.



<workflow>\_<yyyymmdd>\_<sequence>.<extension>



Example:



kontext\_20260711\_0001.jpg



repair\_20260711\_0001.jpg



ccsr\_20260711\_0001.jpg



upscale\_20260711\_0001.jpg



Filename formatting must be configurable.



Logging



Every automation script must produce structured logs.



Logging should include:



workflow started

workflow completed

processing duration

input image

output image

warnings

errors



Logging behaviour must be configurable.



Error Handling



Automation should be fault tolerant.



A failed image must not terminate an entire batch.



Errors should be logged and processing should continue with the next image whenever possible.



Scalability



The automation framework must be designed so that new workflows can be added without modifying existing automation scripts.



The long-term goal is for the addition of a new workflow to require only:



Add the workflow JSON.

Register the workflow in Config.psd1.

Optionally add it to one or more pipelines.



No PowerShell code should require modification.



\---



\## Principle 2 - Restore Before Reconstructing



Every workflow should follow this philosophy.



Restore



↓



Enhance



↓



Reconstruct (only when necessary)



↓



Generate (last resort)



\---



\## Principle 3 - AI Should Be Conservative



If an AI model is uncertain, it should preserve the original image rather than invent new information.



\---



\## Principle 4 - Never Invent History



The workflow must never introduce historical details that were not present in the original photograph unless explicitly approved.



Examples include:



\- clothing

\- jewellery

\- facial hair

\- hairstyles

\- body shape

\- buildings

\- scenery



\---



\## Principle 5 - Authentic Restoration



The desired outcome is:



"This is exactly the same photograph, but it looks like it was taken yesterday."



The goal is restoration, not recreation.



\---



\## Principle 6 - Generation Requires Permission



AI generation should only be used when restoration cannot recover missing information and reconstruction has been approved.



\---



\## Principle 7 - Human Approval



No restoration is considered complete until it has been manually approved.



The AI never makes the final decision.



\---



\## Principle 8 - Measurable Improvement



Every workflow must improve one or more measurable characteristics.



Examples:



\- face clarity

\- sharpness

\- noise reduction

\- scratch removal

\- colour recovery

\- print quality



If measurable improvement cannot be demonstrated, the workflow should not be adopted.

