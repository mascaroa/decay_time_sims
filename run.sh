#!/bin/bash

cat out.txt > log.txt
rm out.txt

# MATLAB path goes here:

# /ltmp/matlab/8.3/bin/matlab -nodisplay -nosplash < decay_time_sims/inputs.m >> out.txt &
/Applications/MATLAB_R2015a.app/bin/matlab -nodisplay -nosplash < decay_time_sims/inputs.m >> out.txt &

tail -f out.txt
