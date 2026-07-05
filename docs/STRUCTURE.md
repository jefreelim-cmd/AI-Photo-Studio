AI Photo Studio - Repository Structure



Version: 0.1.0



Purpose



This document defines the directory structure used throughout the AI Photo Studio platform.



Each folder has a single, clearly defined responsibility.



If a file does not clearly belong in a folder, the structure should be reviewed before adding it.



Platform Layout

D:\\

└── AI-Photo-Studio

&#x20;   │

&#x20;   ├── AI-Photo-Studio      # GitHub Repository

&#x20;   ├── ComfyUI              # Official ComfyUI Repository

&#x20;   ├── assets

&#x20;   ├── models

&#x20;   ├── workflows

&#x20;   ├── input

&#x20;   ├── output

&#x20;   ├── archive

&#x20;   └── logs

GitHub Repository



Location:



D:\\AI-Photo-Studio\\AI-Photo-Studio



Purpose:



Contains all source code, automation, documentation and configuration.



Everything inside this folder is version controlled.



config



Purpose



Central configuration for the platform.



Examples



StudioConfig.psd1



Rules



No hard-coded paths

Single source of truth

Read-only during execution

docs



Purpose



Project documentation.



Examples



README.md

ENGINEERING-STANDARDS.md

STRUCTURE.md

CHANGELOG.md (future)

ROADMAP.md (future)



Rules



Documentation evolves with the project.

Keep documentation concise and current.

manifests



Purpose



Defines AI capabilities through version-controlled manifest files.



Examples



Restoration.psd1

Portrait.psd1

Background.psd1



Rules



Store metadata only.

Do not store downloaded models.

Changes should be committed to Git.

scripts



Purpose



Platform entry points.



Scripts orchestrate modules.



Examples



Install-Studio.ps1

Test-Studio.ps1

Initialize-FolderStructure.ps1



Rules



Scripts contain orchestration only.

Business logic belongs in modules.

src



Purpose



Reusable PowerShell modules.



Core



Purpose



Shared functionality used across the platform.



Examples



Configuration

Logging

Validation

Process

Git

Downloads

FileSystem

Hashing

Archive



Rules



Reusable

Independent

No business-specific logic

Installation



Purpose



Installation and provisioning modules.



Examples



ComfyUI

PythonDependencies

VirtualEnvironment

FolderStructure

Models



Rules



One responsibility per module.

Idempotent.

Validate before installing.

Models



Purpose



Read and process model manifest files.



Responsibilities



Load manifests

Parse model metadata

Support future model management



Rules



No downloading.

No installation.

Read-only responsibilities.

tests



Purpose



Automated validation and future unit tests.



Status



Reserved for future development.



Workspace Directories



The following folders exist outside the GitHub repository.



They contain runtime data and are never committed to source control.



ComfyUI



Purpose



Official ComfyUI repository.



Rules



Managed independently from the AI Photo Studio repository.



models



Purpose



Stores downloaded AI models.



Examples



checkpoints

controlnet

loras

vae

clip

clip\_vision

ipadapter

sam

ultralytics

upscale\_models



Rules



Large binary files.

Never committed to Git.

Managed through automation.

workflows



Purpose



Stores ComfyUI workflow JSON files.



Categories



restoration

portrait

background

upscaling

experiments



Rules



Version-controlled workflows should originate from the repository where appropriate.



assets



Purpose



Reusable project assets.



Examples



branding

fonts

icons

templates

watermarks



Rules



Assets should be reusable across multiple workflows.



input



Purpose



Incoming images awaiting processing.



Categories



restore

portraits

background



Rules



Temporary working data.



output



Purpose



Generated images.



Categories



restore

portraits

background

previews



Rules



Generated output should not be committed to Git.



archive



Purpose



Long-term storage.



Examples



completed jobs

exported projects

historical workflows

logs



Purpose



Application and automation logs.



Future



Centralised logging will be added in a future release.



Design Principles



The directory structure follows these principles:



One responsibility per folder.

Source code belongs in Git.

Runtime data belongs outside Git.

Configuration is centralised.

Automation manages the platform.

Avoid duplicate responsibilities.

Prefer documentation over renaming.

Folder Ownership

Folder	Owner

config	Configuration

docs	Documentation

manifests	AI capability definitions

scripts	Orchestration

src\\Core	Shared platform modules

src\\Installation	Installation modules

src\\Models	Manifest processing

tests	Validation

ComfyUI	Official upstream project

models	AI models

workflows	ComfyUI workflows

assets	Shared resources

input	Incoming data

output	Generated data

archive	Historical data

logs	Platform logging

Continuous Improvement



The structure will evolve as the platform grows.



When adding a new folder:



Define its purpose.

Define its owner.

Document it here.

Keep responsibilities clear.

Avoid overlapping functionality.

