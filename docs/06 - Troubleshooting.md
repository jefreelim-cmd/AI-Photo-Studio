\## CCSR Import Bug



Problem



ModuleNotFoundError:

No module named 'ComfyUI-CCSR'



Cause



Old workflow referenced deprecated package name.



Fix



common.py



Changed:



...



ldm/util.py



Changed:



...



Result



Workflow successfully loads CCSR.

