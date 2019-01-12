#!/bin/bash


# register nodif_brain to wT1_brain, which is in MNI space, output rT2_brain.nii.gz
fsl5.0-flirt -in nodif_brain -ref wT1_brain -out rT2_brain -omat registered_nodif_brain.mat
