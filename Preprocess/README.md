# Preprocess

### T1T2DWI

+ T1 

Skull stripped + Normalized + Remove negative value + Change Datatype to UINT32

Implemented by SPM12 + MATLAB

+ T2

Skull stripped + Registered to MNI Space + Remove negative + Change Datatype to UINT32

Implemented by FSL + MATLAB

+ DWI

Register the features(FA/MD/L1/L2/L3) to MNI Space, using the transformation matrix calculated in the registration of T2.

Implemented by FSL

*The above processing can only be run in UNIX System, because FSL is only supported in UNIX*

### Structure

Use SPM12 and Matlab to process T1 and T2.
