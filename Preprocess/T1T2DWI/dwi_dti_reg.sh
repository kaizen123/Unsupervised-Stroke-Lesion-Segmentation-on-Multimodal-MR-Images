#!/bin/bash

# Register MD/FA to wT1_brain space, using registered_nodif_brain.mat

rm -rf rT2_brain.nii.gz

fsl5.0-flirt -in dtifitresult_MD -applyxfm -init registered_nodif_brain.mat -out rdtifitresult_MD -paddingsize 0.0 -interp trilinear -ref rT2_brain
fsl5.0-flirt -in dtifitresult_FA -applyxfm -init registered_nodif_brain.mat -out rdtifitresult_FA -paddingsize 0.0 -interp trilinear -ref rT2_brain
fsl5.0-flirt -in dtifitresult_L1 -applyxfm -init registered_nodif_brain.mat -out rdtifitresult_L1 -paddingsize 0.0 -interp trilinear -ref rT2_brain
fsl5.0-flirt -in dtifitresult_L2 -applyxfm -init registered_nodif_brain.mat -out rdtifitresult_L2 -paddingsize 0.0 -interp trilinear -ref rT2_brain
fsl5.0-flirt -in dtifitresult_L3 -applyxfm -init registered_nodif_brain.mat -out rdtifitresult_L3 -paddingsize 0.0 -interp trilinear -ref rT2_brain

