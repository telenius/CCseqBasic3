#!/bin/bash

##########################################################################
# Copyright 2017, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
#                                                                        #
# This file is part of CCseqBasic3 .                                     #
#                                                                        #
# CCseqBasic3 is free software: you can redistribute it and/or modify    #
# it under the terms of the MIT license.
#
#
#                                                                        #
# CCseqBasic3 is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# MIT license for more details.
#                                                                        #
# You should have received a copy of the MIT license
# along with CCseqBasic3.  
##########################################################################

cleanUpRunFolder(){
    
# We want to leave somewhat explore-able structure to the output folder..

echo "Cleaning up after ourselves - renaming folders and packing files.."

mv -f RAW_${Sample}_${CC2version} F2_RAW_${Sample}_${CC2version}
mv -f filteringLogFor_RAW_${Sample}_${CC2version} F3_filtering_${Sample}_${CC2version}
mv -f FILTERED_${Sample}_${CC2version} F4_FILTERED_${Sample}_${CC2version}

cd F1_${Sample}_pre${CC2version}
echo F1_${Sample}_pre${CC2version}
samtools view -hb Combined_reads_REdig.sam > Combined_reads_REdig.bam

ls -lht Combined_reads_REdig.bam
rm -f Combined_reads_REdig.sam
rm -f  Combined_reads_REdig.fastq
rm -f  Combined_reads.fastq
cd ..

cd F2_RAW_${Sample}_${CC2version}
echo F2_RAW_${Sample}_${CC2version}
cleanCCfolder
cd ..

cd F4_FILTERED_${Sample}_${CC2version}
echo F4_FILTERED_${Sample}_${CC2version}
cleanCCfolder
cd ..

echo
echo "Output folders generated :"

ls -lht
    
}

