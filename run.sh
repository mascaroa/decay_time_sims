#!/bin/bash

cd /ltmp/mascaroa/decay_time_sims/
cat out.txt > log.txt
rm out.txt
/ltmp/matlab/8.3/bin/matlab -nodisplay -nosplash < /decay_time_sims/inputs.m >> out.txt &
tail -f out.txt
