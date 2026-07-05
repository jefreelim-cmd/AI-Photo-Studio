AI Photo Studio - Engineering Standards

Version: 0.1.0

Purpose

This document defines the engineering standards used throughout the AI Photo Studio project.

These standards ensure the platform remains:

Maintainable
Consistent
Modular
Idempotent
Commercial quality

This is a living document and will evolve as the project matures.

Engineering Principles
Build First, Optimise Later

The priority is to build a working platform.

Refactoring should only occur when it:

Improves maintainability
Removes duplication
Fixes design issues
Enables future functionality

Avoid premature optimisation.

One Outcome Per Step

Development is performed in small, verifiable steps.

Each step should include:

Goal
Action
Definition of Done

Complete one step before moving to the next.

Every Commit Must Work

Every commit represents a stable checkpoint.

Never commit:

Broken code
Partially implemented features
Failing scripts

If it doesn't work, it doesn't get committed.

Verify Before Assuming

Always verify the current system state before making changes.

Examples:

Verify PowerShell exists
Verify Python exists
Verify Git exists
Verify ComfyUI exists
Verify Virtual Environment exists

Never assume.

Development Workflow

Development follows an iterative engineering process.

Keep communication concise and outcome focused.
Complete one step before starting the next.
Verify every change before proceeding.
Capture future improvements in the backlog.
Avoid unnecessary refactoring during feature development.
Build a working solution first.
Improve it incrementally.
Architecture

The platform consists of four layers.

Scripts

↓

Modules

↓

AI Engines

↓

Models

Scripts orchestrate.

Modules implement functionality.

Repository Structure

The GitHub repository contains source code and automation.

config
docs
scripts
src
tests

The workstation contains:

ComfyUI
assets
models
workflows
input
output
archive
logs
Configuration Standards

Configuration is stored in:

config/StudioConfig.psd1

Rules:

No hard-coded paths
Configuration is the single source of truth
All modules read from configuration
PowerShell Standards

Development shell:

PowerShell 7+

PowerShell ISE is not supported.

Use approved PowerShell Verb-Noun naming.

Examples:

Install-ComfyUI
Initialize-FolderStructure
Test-Studio
Write-StudioLog

Every public function should use:

CmdletBinding()
Set-StrictMode
ErrorActionPreference = Stop
Module Standards

Each module has one responsibility.

Examples:

Configuration.psm1
Logging.psm1
Validation.psm1
FolderStructure.psm1
ComfyUI.psm1

Modules should be:

Reusable
Idempotent
Independently testable
Script Standards

Scripts orchestrate.

Business logic belongs inside modules.

Examples:

Install-Studio.ps1
Test-Studio.ps1

Scripts should remain thin.

Logging Standards

All user-facing output should use:

Write-StudioLog

Avoid Write-Host directly inside installation modules.

Future enhancements:

Log files
Verbose mode
Structured logging
Validation Standards

Every installation module should:

Verify
Skip if already installed
Install if required
Validate installation
Log the outcome

All installation modules should be idempotent.

Installation Standards

Every installation module should expose a single public function.

Examples:

Install-ComfyUI
Install-ComfyUIManager
Initialize-VirtualEnvironment
Install-PythonDependencies

Installation modules should never duplicate functionality.

Git Standards

Preferred workflow:

GitHub Desktop
Git CLI when required

Commit message format:

feat:
fix:
docs:
refactor:
test:
chore:

Every commit should represent a working checkpoint.

Documentation Standards

Documentation evolves with the project.

Keep documentation:

Accurate
Concise
Version controlled

Do not document planned functionality as if it already exists.

Automation Philosophy

If a task is repeated:

Automate it.

If code is duplicated:

Refactor it.

If a decision is made:

Document it.

If a process changes:

Update this document.

Project Philosophy

This project is not simply a ComfyUI installation.

It is an automation platform for building, maintaining and operating a commercial AI Photo Studio.

ComfyUI is one component of the platform.

The long-term objective is that a new workstation can be fully configured by executing a single PowerShell script.

Future Enhancements

Items intentionally deferred until later:

Unified PowerShell module structure
Structured logging
Automated testing
Release tagging
CI/CD pipelines
Package publishing
Advanced configuration validation
Automated dependency updates