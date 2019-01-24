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

runFlash(){
    
    echo
    echo "Running flash with parameters :"
    echo " m (minimum overlap) : ${flashOverlap}"
    echo " x (sum-of-mismatches/overlap-lenght) : ${flashErrorTolerance}"
    echo " p phred score min (33 or 64) : ${intQuals}"
    echo
    printThis="flash --interleaved-output -p ${intQuals} -m ${flashOverlap} -x ${flashErrorTolerance} READ1.fastq READ2.fastq > flashing.log"
    printToLogFile
    
    # flash --interleaved-output -p "${intQuals}" READ1.fastq READ2.fastq > flashing.log
    flash --interleaved-output -p "${intQuals}" -m "${flashOverlap}" -x "${flashErrorTolerance}" READ1.fastq READ2.fastq > flashing.log
    
    ls | grep out*fastq
    
    # This outputs these files :
    # flashing.log  out.extendedFrags.fastq  out.hist  out.histogram  out.notCombined.fastq  o

    echo "Read counts after flash :"
    
    flashedCount=0
    unmapped1count=0
    unmapped2count=0
    
    if [ -s "out.extendedFrags.fastq" ] ; then
        flashedCount=$(( $( grep -c "" out.extendedFrags.fastq )/4 ))
    fi
    if [ -s "out.notCombined.fastq" ] ; then
        unmappedcount=$(( $( grep -c "" out.notCombined.fastq )/4 ))
    fi
    
    echo "extendedFrags.fastq (count of read pairs combined in flash) : ${flashedCount}"
    echo "out.notCombined.fastq (not extendable via flash) : ${mapped1count}"
    
}

runCCanalyser(){
    
################################################################
# Running CAPTURE-C analyser for the aligned file..

#sampleForCCanalyser="RAW_${Sample}"
#samForCCanalyser="Combined_reads_REdig.sam"
#runDir=$( pwd )
#samDirForCCanalyser=${runDir}
#publicPathForCCanalyser="${PublicPath}/RAW"
#JamesUrlForCCanalyser="${JamesUrl}/RAW"


printThis="Running CAPTURE-C analyser for the aligned file.."
printToLogFile

testedFile="${OligoFile}"
doTempFileTesting

mkdir -p "${publicPathForCCanalyser}"

printThis="perl ${RunScriptsPath}/${CCscriptname} -f ${samDirForCCanalyser}/${samForCCanalyser} -o ${OligoFile} -r genome_dpnII_coordinates.txt --pf ${publicPathForCCanalyser} --pu ${JamesUrlForCCanalyser} -s ${sampleForCCanalyser} --genome ${GENOME} --ucscsizes ${ucscBuild} ${otherParameters}"
printToLogFile

echo "-f Input filename "
echo "-r Restriction coordinates filename "
echo "-o Oligonucleotide position filename "
echo "--pf Your public folder"
echo "--pu Your public url"
echo "-s Sample name (and the name of the folder it goes into)"
echo "-w Window size (default = 2kb)"
echo "-i Window increment (default = 200bp)"
echo "--dump Print file of unaligned reads (sam format)"
echo "--snp Force all capture points to contain a particular SNP"
echo "--limit Limit the analysis to the first n reads of the file"
echo "--genome Specify the genome (mm9 / hg18)"
echo "--ucscsizes Chromosome sizes file path"
echo "--globin Combines the two captures from the gene duplicates (HbA1 and HbA2)"

runDir=$( pwd )

# Copy used oligo file for archiving purposes..
cp ${OligoFile} usedOligoFile.txt

# remove parameter file from possible earlier run..
rm -f parameters_for_normalisation.log

perl ${RunScriptsPath}/${CCscriptname} -f "${samDirForCCanalyser}/${samForCCanalyser}" -o "${OligoFile}" -r "${fullPathDpnGenome}" --pf "${publicPathForCCanalyser}" --pu "${JamesUrlForCCanalyser}" -s "${sampleForCCanalyser}" --genome "${GENOME}" --ucscsizes "${ucscBuild}" -w "${WINDOW}" -i "${INCREMENT}" ${otherParameters}

echo "Contents of run folder :"
ls -lht

echo
echo "Contents of CCanalyser output folder ( ${sampleForCCanalyser}_${CCversion} ) "
ls -lht ${sampleForCCanalyser}_${CCversion}

echo
echo "Counts of output files - by file type :"

count=$( ls -1 ${publicPathForCCanalyser} | grep -c '.bw' )
echo
echo "${count} bigwig files (should be x2 the amount of oligos, if all had captures)"

count=$( ls -1 ${sampleForCCanalyser}_${CCversion} | grep -c '.wig' )
echo
echo "${count} wig files (should be x2 the amount of oligos, if all had captures)"

count=$( ls -1 ${sampleForCCanalyser}_${CCversion} | grep -c '.gff' )
echo
echo "${count} gff files (should be x1 the amount of oligos, if all had captures)"

echo
echo "Output log files :"
ls -1 ${sampleForCCanalyser}_${CCversion} | grep '.txt'

echo
echo "Bed files :"
ls -1 ${sampleForCCanalyser}_${CCversion} | grep '.bed'

echo
echo "Sam files :"
ls -1 ${sampleForCCanalyser}_${CCversion} | grep '.sam'

echo
echo "Fastq files :"
ls -1 ${sampleForCCanalyser}_${CCversion} | grep '.fastq'   
    
}



cleanCCfolder(){
rm -f *_coordstring_${CCversion}.txt
for file in *.sam
do
    bamname=$( echo $file | sed 's/.sam/.bam/' )
    if [ -s ${file} ]
    then
    samtools view -bh ${file} > ${bamname}
    fi
    
    rm -f $file
    ls -lht ${bamname}
done
}

cleanUpRunFolder(){
    
# We want to leave somewhat explore-able structure to the output folder..

echo "Cleaning up after ourselves - renaming folders and packing files.."

mv -f RAW_${Sample}_${CCversion} F2_RAW_${Sample}_${CCversion}
mv -f filteringLogFor_RAW_${Sample}_${CCversion} F3_filtering_${Sample}_${CCversion}
mv -f FILTERED_${Sample}_${CCversion} F4_FILTERED_${Sample}_${CCversion}

cd F1_${Sample}_pre${CCversion}
echo F1_${Sample}_pre${CCversion}
samtools view -hb Combined_reads_REdig.sam > Combined_reads_REdig.bam

ls -lht Combined_reads_REdig.bam
rm -f Combined_reads_REdig.sam
rm -f  Combined_reads_REdig.fastq
rm -f  Combined_reads.fastq
cd ..

cd F2_RAW_${Sample}_${CCversion}
echo F2_RAW_${Sample}_${CCversion}
cleanCCfolder
cd ..

cd F4_FILTERED_${Sample}_${CCversion}
echo F4_FILTERED_${Sample}_${CCversion}
cleanCCfolder
cd ..

echo
echo "Output folders generated :"

ls -lht
    
}

