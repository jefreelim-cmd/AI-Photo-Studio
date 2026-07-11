\# Decision Log



This document records the major architectural decisions made throughout the development of the AI Photo Studio.



\---



\## Decision 001



\### Title



Project Mission



\### Date



2026-07-06



\### Decision



The AI Photo Studio will focus on restoring and preserving photographs rather than generating AI artwork.



\### Reason



The primary objective of this project is to preserve family memories while maintaining authenticity and historical integrity.



\---



\## Decision 002



\### Title



Restoration Philosophy



\### Date



2026-07-06



\### Decision



Every workflow will follow the philosophy:



Restore



↓



Enhance



↓



Reconstruct (only if necessary)



↓



Generate (last resort)



\### Reason



The project exists to restore existing photographs, not recreate them.



\---



\## Decision 003



\### Title



Identity Preservation



\### Date



2026-07-06



\### Decision



Identity preservation has higher priority than maximum sharpness.



\### Reason



A softer photograph is preferable to one that changes a person's appearance.



\---



\## Decision 004



\### Title



Historical Authenticity



\### Date



2026-07-06



\### Decision



Workflows must never invent historical details unless explicitly approved.



\### Examples



\- clothing

\- jewellery

\- hairstyles

\- facial hair

\- buildings

\- scenery



\### Reason



Historical photographs should remain historically accurate.



\---



\## Decision 005



\### Title



Human Approval



\### Date



2026-07-06



\### Decision



No restoration is considered complete until it receives manual approval.



\### Reason



AI assists restoration.



Humans make the final decision.



\---



\## Decision 006



\### Title



Workflow Architecture



\### Date



2026-07-06



\### Decision



The AI Photo Studio will be built using small, reusable modules rather than large monolithic workflows.



\### Reason



Modular workflows are easier to understand, benchmark, maintain and improve.



\---



\## Decision 007



\### Title



Workflow Development Process



\### Date



2026-07-06



\### Decision



Every workflow will be:



\- researched

\- designed

\- built

\- tested

\- benchmarked

\- documented

\- versioned



before becoming part of the production library.



\### Reason



Maintain a high-quality and trusted workflow library.



\---



\## Decision 008



\### Title



Technology Selection



\### Date



2026-07-06



\### Decision



Models and custom nodes will only be installed when they directly support an approved workflow.



\### Reason



Keep the ComfyUI environment clean, maintainable and focused.



\---



\## Decision 009



\### Title



Workflow Storage



\### Date



2026-07-06



\### Decision



Workflows will be saved using ComfyUI and then moved into organised folders.



\### Folder Structure



\- upscaling

\- restoration

\- portrait

\- background

\- experiments



\### Reason



Maintain a scalable workflow library while remaining compatible with ComfyUI.



\---



\## Decision 010



\### Title



Benchmark Driven Development



\### Date



2026-07-06



\### Decision



Workflow adoption will be based on benchmark results rather than popularity.



\### Reason



Objective measurements produce better long-term decisions than trends.





\## 2026-07-07



\### Objective

Evaluate a higher quality photo restoration workflow.



\### Workflow

\- CCSR + SUPIR Ultimate Restoration

\- Source: <GitHub URL>



\### Decisions

\- Installed missing custom nodes.

\- Downloaded missing models.

\- Replaced CCSR\_Model\_Select with DownloadAndLoadCCSRModel.

\- Patched CCSR import compatibility for modern ComfyUI.

\- Successfully progressed workflow to CCSR\_Upscale.



\### Outcome

Workflow now executes successfully.

Quality evaluation pending.

