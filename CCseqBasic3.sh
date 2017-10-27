#!/bin/bash

##########################################################################
# Copyright 2017, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
#                                                                        #
# This file is part of CCseqBasic3 .                                     #
#                                                                        #
# CCseqBasic3 is free software: you can redistribute it and/or modify    #
# it under the terms of the GNU General Public License as published by   #
# the Free Software Foundation, either version 3 of the License, or      #
# (at your option) any later version.                                    #
#                                                                        #
# CCseqBasic3 is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# GNU General Public License for more details.                           #
#                                                                        #
# You should have received a copy of the GNU General Public License      #
# along with CCseqBasic3.  If not, see <http://www.gnu.org/licenses/>.   #
##########################################################################

#------------------------------------------
# The codes of the pipeline 
#------------------------------------------
#
# CCseqBasic3/
#
# |
# |-- CCseqBasic3.sh
# |
# `-- bin
#     |
#     |-- runscripts
#     |   |
#     |   |-- analyseMappedReads.pl
#     |   |-- analyseMappedReads_noduplFilter.pl
#     |   |-- dpnIIcutGenome.pl
#     |   |-- dpnIIcutReads.pl
#     |   |
#     |   `-- filterArtifactMappers
#     |       |
#     |       |-- 1_blat.sh
#     |       |-- 2_psl_parser.pl
#     |       `-- filter.sh
#     |   
#     `-- subroutines
#         |-- cleaners.sh
#         |-- hubbers.sh
#         |-- parametersetters.sh
#         |-- runtools.sh
#         |-- testers_and_loggers.sh
#         `-- usageAndVersion.sh

#------------------------------------------

function finish {
if [ $? != "0" ]; then
echo
echo "RUN CRASHED ! - check qsub.err to see why !"
echo
echo "If your run passed folder1 (F1) succesfully - i.e. you have F2 or later folders formed correctly - you can restart in same folder, same run.sh :"
echo "Just add --onlyCCanalyser to the end of run command in run.sh, and start the run normally, in the same folder you crashed now (this will overrwrite your run from bowtie output onwards)."
echo
echo "If you are going to rerun a crashed run without using --onlyCCanalyser , copy your run script to a NEW EMPTY FOLDER,"
echo "and remember to delete your malformed /public/ hub-folders (especially the tracks.txt files) to avoid wrongly generated data hubs (if you are going to use same SAMPLE NAME as in the crashed run)" 
echo

else
echo
echo "Analysis complete !"
date

fi
}
trap finish EXIT

#------------------------------------------

QSUBOUTFILE="qsub.out"
QSUBERRFILE="qsub.err"

OligoFile=""
TRIM=1
GENOME=""
WINDOW=200
INCREMENT=20
CAPITAL_M=0
LOWERCASE_M=0
BOWTIEMEMORY="256"
Sample="sample"
Read1=""
Read2=""

CUSTOMAD=-1
ADA31="no"
ADA32="no"

# trimgalore default
QMIN=20

# bowtie default
BOWTIE=1

# flash defaults
flashOverlap=10
flashErrorTolerance=0.25

saveDpnGenome=1

ucscBuild=""
bowtieGenome=""
otherBowtieParameters=""
bowtie1MismatchBehavior=""
bowtie2MismatchBehavior=""

otherParameters=""
PublicPath="UNDETERMINED"

ploidyFilter=""
extend=20000

REenzyme="dpnII"

# Skip other stages - assume input from this run has been ran earlier - to construct to THIS SAME FOLDER everything else
# but as the captureC analyser naturally crashed - this will jump right to the beginning of that part..
ONLY_CC_ANALYSER=0
# Rerun public folder generation and filling. Will not delete existing folder, but will overwrite all files (and start tracks.txt from scratch).
ONLY_HUB=0

#------------------------------------------

CCversion="CB3"
captureScript="analyseMappedReads"
CCseqBasicVersion="CCseqBasic3"

echo "${CCseqBasicVersion}.sh - by Jelena Telenius, 05/01/2016"
echo
timepoint=$( date )
echo "run started : ${timepoint}"
echo
echo "Script located at"
echo "$0"
echo

echo "RUNNING IN MACHINE : "
hostname --long

echo "run called with parameters :"
echo "${CCseqBasicVersion}.sh" $@
echo

#------------------------------------------

# Loading subroutines in ..

echo "Loading subroutines in .."

CaptureTopPath="$( echo $0 | sed 's/\/'${CCseqBasicVersion}'.sh$//' )"

CapturePipePath="${CaptureTopPath}/bin/subroutines"

# HUBBING subroutines
. ${CapturePipePath}/hubbers.sh

# SETTING parameter values - subroutines
. ${CapturePipePath}/parametersetters.sh

# CLEANING folders and organising structures
. ${CapturePipePath}/cleaners.sh

# TESTING file existence, log file output general messages
. ${CapturePipePath}/testers_and_loggers.sh

# RUNNING the main tools (flash, ccanalyser, etc..)
. ${CapturePipePath}/runtools.sh

# SETTING THE GENOME BUILD PARAMETERS
. ${CapturePipePath}/genomeSetters.sh

# SETTING THE BLACKLIST GENOME LIST PARAMETERS
. ${CapturePipePath}/blacklistSetters.sh

# PRINTING HELP AND VERSION MESSAGES
. ${CapturePipePath}/usageAndVersion.sh

#------------------------------------------

# From where to call the main scripts operating from the runscripts folder..

RunScriptsPath="${CaptureTopPath}/bin/runscripts"

#------------------------------------------

# From where to call the filtering scripts..
# (blacklisting regions with BLACKLIST pre-made region list, as well as on-the-fly BLAT-hit based "false positive" hits) 

CaptureFilterPath="${RunScriptsPath}/filterArtifactMappers"

#------------------------------------------

# From where to call the CONFIGURATION script..

confFolder="${CaptureTopPath}/conf"

#------------------------------------------

echo
echo "CaptureTopPath ${CaptureTopPath}"
echo "CapturePipePath ${CapturePipePath}"
echo "confFolder ${confFolder}"
echo "RunScriptsPath ${RunScriptsPath}"
echo "CaptureFilterPath ${CaptureFilterPath}"
echo

#------------------------------------------

# Calling in the CONFIGURATION script and its default setup :

echo "Calling in the conf/config.sh script and its default setup .."

CaptureDigestPath="NOT_IN_USE"
supportedGenomes=()
BOWTIE1=()
BOWTIE2=()
UCSC=()
genomesWhichHaveBlacklist=()
BLACKLIST=()

# . ${confFolder}/config.sh
. ${confFolder}/genomeBuildSetup.sh
. ${confFolder}/loadNeededTools.sh
. ${confFolder}/serverAddressAndPublicDiskSetup.sh

setConfigLocations

echo 
echo "Supported genomes : "
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do echo -n "${supportedGenomes[$g]} "; done
echo 
echo

echo 
echo "Blacklist filtering available for these genomes : "
for g in $( seq 0 $((${#genomesWhichHaveBlacklist[@]}-1)) ); do echo -n "${genomesWhichHaveBlacklist[$g]} "; done
echo 
echo 

#------------------------------------------


OPTS=`getopt -o h,m:,M:,o:,s:,w:,i:,v: --long help,dump,snp,globin:,limit:,pf:,genome:,outfile:,errfile:,R1:,R2:,saveGenomeDigest,dontSaveGenomeDigest,trim,noTrim,chunkmb:,bowtie1,bowtie2,window:,increment:,ada3read1:,ada3read2:,extend:,onlyCCanalyser,onlyHub,noPloidyFilter:,qmin:,flashBases:,flashMismatch:,stringent,trim3:,trim5:,seedmms:,seedlen:,maqerr: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

while true ; do
    case "$1" in
        -h) usage ; shift;;
        -m) LOWERCASE_M=$2 ; shift 2;;
        -M) CAPITAL_M=$2 ; shift 2;;
        -o) OligoFile=$2 ; shift 2;;
        -w) WINDOW=$2 ; shift 2;;
        -i) INCREMENT=$2 ; shift 2;;
        -s) Sample=$2 ; shift 2;;
        -v) LOWERCASE_V="$2"; shift 2;;
        --help) usage ; shift;;
        --onlyCCanalyser) ONLY_CC_ANALYSER=1 ; shift;;
        --onlyHub) ONLY_HUB=1 ; shift;;
        --R1) Read1=$2 ; shift 2;;
        --R2) Read2=$2 ; shift 2;;
        --chunkmb) BOWTIEMEMORY=$2 ; shift 2;;
        --bowtie1) BOWTIE=1 ; shift;;
        --bowtie2) BOWTIE=2 ; shift;;
        --saveGenomeDigest) saveDpnGenome=1 ; shift;;
        --dontSaveGenomeDigest) saveDpnGenome=0 ; shift;;
        --trim) TRIM=1 ; shift;;
        --noTrim) TRIM=0 ; shift;;
        --window) WINDOW=$2 ; shift 2;;
        --increment) INCREMENT=$2 ; shift 2;;
        --genome) GENOME=$2 ; shift 2;;
        --ada3read1) ADA31=$2 ; shift 2;;
        --ada3read2) ADA32=$2 ; shift 2;;
        --extend) extend=$2 ; shift 2;;
        --noPloidyFilter) ploidyFilter="--noploidyfilter " ; shift;;
        --dump) otherParameters="$otherParameters --dump" ; shift;;
        --snp) otherParameters="$otherParameters --snp" ; shift;;
        --globin) otherParameters="$otherParameters --globin $2" ; shift 2;;
        --limit) otherParameters="$otherParameters --limit $2" ; shift 2;;
        --stringent) otherParameters="$otherParameters --stringent" ; shift 1;;
        --pf) PublicPath="$2" ; shift 2;;
        --qmin) QMIN="$2" ; shift 2;;
        --flashBases) flashOverlap="$2" ; shift 2;;
        --flashMismatch) flashErrorTolerance="$2" ; shift 2;;
        --trim3) otherBowtieParameters="${otherBowtieParameters} --trim3 $2 " ; shift 2;;
        --trim5) otherBowtieParameters="${otherBowtieParameters} --trim5 $2 " ; shift 2;;
        --seedmms) bowtieMismatchBehavior="${bowtie1MismatchBehavior} --seedmms $2 " ; ${bowtie2MismatchBehavior}="${bowtie2MismatchBehavior} -N $2 "  ; shift 2;;
        --seedlen) bowtieMismatchBehavior="${bowtie1MismatchBehavior} --seedlen $2 " ; ${bowtie2MismatchBehavior}="${bowtie2MismatchBehavior} -L $2 " ; shift 2;;
        --maqerr) bowtieMismatchBehavior="${bowtieMismatchBehavior} --maqerr $2 " ; shift 2;;
        --outfile) QSUBOUTFILE=$2 ; shift 2;;
        --errfile) QSUBERRFILE=$2 ; shift 2;;
        --) shift; break;;
    esac
done

# ----------------------------------------------

# Modifying and adjusting parameter values, based on run flags

setBOWTIEgenomeSizes
setGenomeFasta

echo "GenomeFasta ${GenomeFasta}" >> parameters_capc.log
echo "BowtieGenome ${BowtieGenome}" >> parameters_capc.log

setUCSCgenomeSizes

echo "ucscBuild ${ucscBuild}" >> parameters_capc.log

#------------------------------------------

CaptureDigestPath="${CaptureDigestPath}/${REenzyme}"

setParameters

# ----------------------------------------------

# Loading the environment - either with module system or setting them into path.
# This subroutine comes from conf/config.sh file

printThis="LOADING RUNNING ENVIRONMENT"
printToLogFile

setPathsForPipe

#---------------------------------------------------------

echo "Run with parameters :"
echo
echo "Output log file ${QSUBOUTFILE}" > parameters_capc.log
echo "Output error log file ${QSUBERRFILE}" >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log
echo "CaptureTopPath ${CaptureTopPath}" >> parameters_capc.log
echo "CapturePipePath ${CapturePipePath}" >> parameters_capc.log
echo "confFolder ${confFolder}" >> parameters_capc.log
echo "RunScriptsPath ${RunScriptsPath}" >> parameters_capc.log
echo "CaptureFilterPath ${CaptureFilterPath}" >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log
echo "Sample ${Sample}" >> parameters_capc.log
echo "Read1 ${Read1}" >> parameters_capc.log
echo "Read2 ${Read2}" >> parameters_capc.log
echo "GENOME ${GENOME}" >> parameters_capc.log
echo "GenomeIndex ${GenomeIndex}" >> parameters_capc.log
echo "OligoFile ${OligoFile}" >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log
echo "BOWTIEMEMORY ${BOWTIEMEMORY}"  >> parameters_capc.log
echo "CAPITAL_M ${CAPITAL_M}" >> parameters_capc.log
echo "LOWERCASE_M ${LOWERCASE_M}" >> parameters_capc.log
echo "otherBowtieParameters ${otherBowtieParameters}  --best --strata"  >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log
echo "TRIM ${TRIM}  (TRUE=1, FALSE=0)" >> parameters_capc.log
echo "QMIN ${QMIN}  (default 20)" >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log
echo "flashOverlap ${flashOverlap} (default 10)"  >> parameters_capc.log
echo "flashErrorTolerance ${flashErrorTolerance} (default 0.25)"  >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log
echo "WINDOW ${WINDOW}" >> parameters_capc.log
echo "INCREMENT ${INCREMENT}" >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log
echo "saveDpnGenome ${saveDpnGenome}  (TRUE=1, FALSE=0)" >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log
   
echo "CUSTOMAD ${CUSTOMAD}   (TRUE=1, FALSE= -1)"  >> parameters_capc.log

if [ "${CUSTOMAD}" -ne -1 ]; then

echo "ADA31 ${ADA31}"  >> parameters_capc.log
echo "ADA32 ${ADA32}"  >> parameters_capc.log
   
fi

echo "------------------------------" >> parameters_capc.log
echo "ploidyFilter ${ploidyFilter}"  >> parameters_capc.log
echo "extend ${extend}"  >> parameters_capc.log
echo "------------------------------" >> parameters_capc.log

PublicPath="${PublicPath}/${Sample}/${CCversion}"
echo "PublicPath ${PublicPath}" >> parameters_capc.log
ServerUrl="sara.molbiol.ox.ac.uk"
tempJamesUrl="${ServerUrl}/${PublicPath}"
JamesUrl=$( echo ${tempJamesUrl} | sed 's/\/\//\//g' )
ServerAndPath="http://${JamesUrl}"
echo "ServerUrl ${ServerUrl}" >> parameters_capc.log
echo "JamesUrl ${JamesUrl}" >> parameters_capc.log
echo "ServerAndPath ${ServerAndPath}" >> parameters_capc.log
echo "otherParameters ${otherParameters}" >> parameters_capc.log
echo
# The public paths are just listed here, not used.
# They will be separately fetched again, in the dataHubGenerator.sh
echo "SERVERTYPE ${SERVERTYPE}" >> parameters.log
echo "SERVERADDRESS ${SERVERADDRESS}" >> parameters.log
echo "ADDtoPUBLICFILEPATH ${ADDtoPUBLICFILEPATH}" >> parameters.log
echo "REMOVEfromPUBLICFILEPATH ${REMOVEfromPUBLICFILEPATH}" >> parameters.log
echo "tobeREPLACEDinPUBLICFILEPATH ${tobeREPLACEDinPUBLICFILEPATH}" >> parameters.log
echo "REPLACEwithThisInPUBLICFILEPATH ${REPLACEwithThisInPUBLICFILEPATH}" >> parameters.log
echo
echo "GenomeFasta ${GenomeFasta}" >> parameters_capc.log
echo "BowtieGenome ${BowtieGenome}" >> parameters_capc.log
echo "ucscBuild ${ucscBuild}" >> parameters_capc.log

cat parameters_capc.log
echo

echo "Whole genome fasta file path : ${GenomeFasta}"
echo "Bowtie genome index path : ${BowtieGenome}"
echo "Chromosome sizes for UCSC bigBed generation will be red from : ${ucscBuild}"

testedFile="${OligoFile}"
doInputFileTesting

# Making output folder..
if [[ ${ONLY_HUB} -eq "0" ]]; then
if [[ ${ONLY_CC_ANALYSER} -eq "0" ]]; then
mkdir F1_${Sample}_pre${CCversion}   
fi
fi

if [[ ${ONLY_HUB} -eq "0" ]]; then
if [[ ${ONLY_CC_ANALYSER} -eq "0" ]]; then

# Copy files over..

testedFile="${Read1}"
doInputFileTesting
testedFile="${Read2}"
doInputFileTesting

if [ "${Read1}" != "READ1.fastq" ] ; then
printThis="Copying input file R1.."
printToLogFile
cp "${Read1}" F1_${Sample}_pre${CCversion}/READ1.fastq
else
printThis="Making safety copy of the original READ1.fastq : READ1.fastq_original.."
printToLogFile
cp "${Read1}" F1_${Sample}_pre${CCversion}/READ1.fastq_original
fi
doQuotaTesting

if [ "${Read2}" != "READ2.fastq" ] ; then
printThis="Copying input file R2.."
printToLogFile
cp "${Read2}" F1_${Sample}_pre${CCversion}/READ2.fastq
else
printThis="Making safety copy of the original READ2.fastq : READ2.fastq_original.."
printToLogFile
cp "${Read2}" F1_${Sample}_pre${CCversion}/READ2.fastq_original
fi
doQuotaTesting

testedFile="F1_${Sample}_pre${CCversion}/READ1.fastq"
doTempFileTesting
testedFile="F1_${Sample}_pre${CCversion}/READ2.fastq"
doTempFileTesting

# Save oligo file full path (to not to lose the file when we cd into the folder, if we used relative paths ! )
OligoFile=$( fp ${OligoFile} )

testedFile="${OligoFile}"
doInputFileTesting

fi
fi

# Go into output folder..
cd F1_${Sample}_pre${CCversion}

if [[ ${ONLY_HUB} -eq "0" ]]; then
if [[ ${ONLY_CC_ANALYSER} -eq "0" ]]; then

################################################################
#Check BOWTIE quality scores..

printThis="Checking the quality score scheme of the fastq files.."
printToLogFile
    
    bowtieQuals=""
    LineCount=$(($( grep -c "" READ1.fastq )/4))
    if [ "${LineCount}" -gt 100000 ] ; then
        bowtieQuals=$( perl ${RunScriptsPath}/fastq_scores_bowtie${BOWTIE}.pl -i READ1.fastq -r 90000 )
    else
        rounds=$((${LineCount}-10))
        bowtieQuals=$( perl ${RunScriptsPath}/fastq_scores_bowtie${BOWTIE}.pl -i READ1.fastq -r ${rounds} )
    fi
    
    echo "Flash, Trim_galore and Bowtie will be ran in quality score scheme : ${bowtieQuals}"

    # The location of "zero" for the filtering/trimming programs cutadapt, trim_galore, flash    
    intQuals=""
    if [ "${bowtieQuals}" = "--phred33-quals" ] ; then
        intQuals="33"
    else
        # Both solexa and illumina phred64 have their "zero point" in 64
        intQuals="64"
    fi

################################################################
# Fastq for original files..
printThis="Running fastQC for input files.."
printToLogFile

printThis="${RunScriptsPath}/QC_and_Trimming.sh --fastqc"
printToLogFile

${RunScriptsPath}/QC_and_Trimming.sh --fastqc

    # Changing names of fastqc folders to be "ORIGINAL"
    mv -f READ1_fastqc READ1_fastqc_ORIGINAL
    mv -f READ2_fastqc READ2_fastqc_ORIGINAL
    mv -f READ1_fastqc.zip READ1_fastqc_ORIGINAL.zip
    mv -f READ2_fastqc.zip READ1_fastqc_ORIGINAL.zip
   
    ls -lht

################################################################
# Trimgalore for the reads..

if [[ ${TRIM} -eq "1" ]]; then

printThis="Running trim_galore for the reads.."
printToLogFile

printThis="${RunScriptsPath}/QC_and_Trimming.sh -q ${intQuals} --filter 3"
printToLogFile

${RunScriptsPath}/QC_and_Trimming.sh -q "${intQuals}" --filter 3

ls -lht

testedFile="READ1.fastq"
doTempFileTesting
testedFile="READ2.fastq"
doTempFileTesting

################################################################
# Fastq for trimmed files..
printThis="Running fastQC for trimmed files.."
printToLogFile

printThis="${RunScriptsPath}/QC_and_Trimming.sh --fastqc"
printToLogFile

${RunScriptsPath}/QC_and_Trimming.sh --fastqc

    # Changing names of fastqc folders to be "TRIMMED"
    mv -f READ1_fastqc READ1_fastqc_TRIMMED
    mv -f READ2_fastqc READ2_fastqc_TRIMMED
    mv -f READ1_fastqc.zip READ1_fastqc_TRIMMED.zip
    mv -f READ2_fastqc.zip READ2_fastqc_TRIMMED.zip
    
fi
    
################################################################
# FLASH for trimmed files..
printThis="Running FLASH for trimmed files.."
printToLogFile

runFlash

ls -lht

printThis="Combining FLASHed files.."
printToLogFile

cat out.notCombined.fastq out.extendedFrags.fastq > Combined_reads.fastq
ls -lht
doQuotaTesting

testedFile="Combined_reads.fastq"
doTempFileTesting

rm -f out.notCombined.fastq out.extendedFrags.fastq
rm -f READ1.fastq READ2.fastq

################################################################
# Fastq for flashed files..
printThis="Running fastQC for FLASHed files.."
printToLogFile

echo "RUNNING FASTQC .."

printThis="fastqc --quiet -f fastq Combined_reads.fastq"
printToLogFile

fastqc --quiet -f fastq Combined_reads.fastq


################################################################
# Running dpnII digestion for combined file..
printThis="Running ${REenzyme} digestion for combined file.."
printToLogFile

printThis="perl ${RunScriptsPath}/${REenzyme}cutReads3.pl Combined_reads.fastq"
printToLogFile

perl ${RunScriptsPath}/${REenzyme}cutReads3.pl Combined_reads.fastq

testedFile="Combined_reads_REdig.fastq"
doTempFileTesting

doQuotaTesting

################################################################
# Running Bowtie for the digested file..
printThis="Running Bowtie for the digested file.."
printToLogFile

echo "Beginning bowtie run (outputting run command after completion) .."
setMparameter

if [ "${BOWTIE}" -eq 2 ] ; then
bowtie2 -p 1 ${otherBowtie2Parameters} ${bowtieQuals} --maxins ${MAXINS} -x ${bowtieGenomeBuild} Combined_reads_REdig.fastq > Combined_reads_REdig.sam
echo "bowtie2 -p 1 ${otherBowtie2Parameters} ${bowtieQuals} --maxins ${MAXINS} -x ${bowtieGenomeBuild} FLASHED_REdig.fastq"
else
bowtie -p 1 --chunkmb "${BOWTIEMEMORY}" ${otherBowtie1Parameters} ${bowtieQuals} ${mParameter} --best --strata --sam "${BowtieGenome}" Combined_reads_REdig.fastq > Combined_reads_REdig.sam
fi

#bowtie -p 1 -m 2 --best --strata --sam --chunkmb 256 ${bowtieQuals} "${BowtieGenome}" Combined_reads_REdig.fastq Combined_reads_REdig.sam

testedFile="Combined_reads_REdig.sam"
doTempFileTesting

doQuotaTesting

samtools view -SH Combined_reads_REdig.sam | grep bowtie

################################################################
# Running whole genome fasta dpnII digestion..

rm -f genome_${REenzyme}_coordinates.txt

if [ -s ${CaptureDigestPath}/${GENOME}.txt ]
then
    
ln -s ${CaptureDigestPath}/${GENOME}.txt genome_${REenzyme}_coordinates.txt
    
else
    
    
# Running the digestion ..
# dpnIIcutGenome.pl
# nlaIIIcutGenome.pl   

printThis="Running whole genome fasta ${REenzyme} digestion.."
printToLogFile

printThis="perl ${RunScriptsPath}/${REenzyme}cutGenome3.pl ${GenomeFasta}"
printToLogFile

perl ${RunScriptsPath}/${REenzyme}cutGenome3.pl "${GenomeFasta}"

testedFile="genome_${REenzyme}_coordinates.txt"
doTempFileTesting

doQuotaTesting

fi

ls -lht


else
# This is the "ONLY_CC_ANALYSER" end fi - if testrun, skipped everything before this point :
# assuming existing output on the above mentioned files - all correctly formed except captureC output !
echo
echo "RE-RUN ! - running only capC analyser script, and filtering (assuming previous pipeline output in the run folder)"
echo

# Here deleting the existing - and failed - capturec analysis directory. not touching public files.

    rm -rf "../F2_RAW_${Sample}_${CCversion}"
    rm -rf "../F3_filtering_${Sample}_${CCversion}"
    rm -rf "../F4_FILTERED_${Sample}_${CCversion}"
    
# Remove the malformed public folder for a new try..
    rm -rf ${PublicPath}
    rm -rf "../PERMANENT_BIGWIGS_do_not_move"
    
# Restoring the input sam file..

# Run crash : we will have SAM instead of bam - if we don't check existence here, we will overwrite (due to funny glitch in samtools 1.1 )
if [ ! -s Combined_reads_REdig.sam ]
then
    samtools view -h Combined_reads_REdig.bam > TEMP.sam
    mv -f TEMP.sam Combined_reads_REdig.sam
    if [ -s Combined_reads_REdig.sam ]; then
        rm -f Combined_reads_REdig.bam
    else
        echo "EXITING ! : Couldn't make Combined_reads_REdig.sam from Combined_reads_REdig.bam" >> "/dev/stderr"
        exit 1
    fi
fi
    
fi

################################################################
# Store the pre-CCanalyser log files for metadata html

copyPreCCanalyserLogFilesToPublic


dpnGenomeName=$( echo "${GenomeFasta}" | sed 's/.*\///' | sed 's/\..*//' )
# output file :
# ${GenomeFasta}_dpnII_coordinates.txt

testedFile="genome_dpnII_coordinates.txt"
doTempFileTesting
fullPathDpnGenome=$( fp "genome_dpnII_coordinates.txt" )
testedFile="${fullPathDpnGenome}"
doTempFileTesting

cd ..

################################################################
# Running CAPTURE-C analyser for the aligned file..

sampleForCCanalyser="RAW_${Sample}"

samForCCanalyser="F1_${Sample}_pre${CCversion}/Combined_reads_REdig.sam"
RAWsamBasename=$( echo ${samForCCanalyser} | sed 's/.*\///' | sed 's/\.sam$//' )

testedFile="${samForCCanalyser}"
doTempFileTesting

runDir=$( pwd )
samDirForCCanalyser=${runDir}
dirForQuotaAsking=${runDir}

publicPathForCCanalyser="${PublicPath}/RAW"
JamesUrlForCCanalyser="${JamesUrl}/RAW"

CCscriptname="${captureScript}.pl"
rm -f parameters_for_filtering.log


runCCanalyser
doQuotaTesting


else
# This is the "ONLY_HUB" end fi - if only hubbing, skipped everything before this point :
# assuming existing output on the above mentioned files - all correctly formed except the public folder (assumes correctly generated bigwigs, however) !
echo
echo "RE-HUB ! - running only public tracks.txt file update (assumes existing bigwig files and other hub structure)."
echo "If your bigwig files are missing (you see no .bw files in ${publicPathForCCanalyser}, or you wish to RE-LOCATE your data hub, run with --onlyCCanalyser parameter (instead of the --onlyHub parameter)"
echo "This is because parts of the hub generation are done inside captureC analyser script, and this assumes only tracks.txt generation failed."
echo

# Remove the malformed tracks.txt for a new try..
#rm -f ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
rm -f ${PublicPath}/RAW/RAW_${Sample}_${CCversion}_tracks.txt
rm -f ${PublicPath}/FILTERED/FILTERED_${Sample}_${CCversion}_tracks.txt
rm -f ${PublicPath}/${Sample}_${CCversion}_tracks.txt

fi


################################################################
# Updating the public folder with analysis log files..

# to create file named ${Sample}_description.html - and link it to each of the tracks.

subfolder="RAW"
updateCCanalyserDataHub


##################################
# Filtering the data..
printThis="##################################"
printToLogFile
printThis="Ploidy filtering and blat-filtering the data.."
printToLogFile
printThis="##################################"
printToLogFile

# ${CaptureFilterPath}
# /home/molhaem2/telenius/CC2/filter/VS101/filter.sh -p parameters.txt --outputToRunfolder --extend 30000
#
#        -p) parameterfile=$2 ; shift 2;;
#        --parameterfile) parameterfile=$2 ; shift 2;;
#        --noploidyfilter) ploidyfilter=0 ; shift 1;;
#        --pipelinecall) pipelinecall=1 ; shift 1;;
#        --extend) extend=$2 ; shift 2;;

echo "${CaptureFilterPath}/filter.sh -p parameters_for_filtering.log --pipelinecall ${ploidyFilter} --extend ${extend}"
echo "${CaptureFilterPath}/filter.sh -p parameters_for_filtering.log --pipelinecall ${ploidyFilter} --extend ${extend}"  >> "/dev/stderr"

mkdir filteringLogFor_${sampleForCCanalyser}_${CCversion}
cp parameters_for_filtering.log filteringLogFor_${sampleForCCanalyser}_${CCversion}/.
cd filteringLogFor_${sampleForCCanalyser}_${CCversion}

${CaptureFilterPath}/filter.sh -p parameters_for_filtering.log --pipelinecall ${ploidyFilter} --extend ${extend}

cd ..

# By default the output of this will go to :
# ${Sample}_${CCversion}/BLAT_PLOIDY_FILTERED_OUTPUT
# because the parameter file line for data location is
# ${Sample}_${CCversion}

printThis="##################################"
printToLogFile
printThis="Re-running CCanalyser for the filtered data.."
printToLogFile
printThis="##################################"
printToLogFile

# keeping the "RAW" in the file name - as this part (input folder location) still needs that
samForCCanalyser="filteringLogFor_${sampleForCCanalyser}_${CCversion}/BlatPloidyFilterRun/BLAT_PLOIDY_FILTERED_OUTPUT/filtered_combined.sam"
FILTEREDsamBasename=$( echo ${samForCCanalyser} | sed 's/.*\///' | sed 's/\.sam$//' )
testedFile="${samForCCanalyser}"
doTempFileTesting
runDir=$( pwd )
samDirForCCanalyser="${runDir}"

# Now changing the identifier from "RAW" to "FILTERED" - to set the output folder
sampleForCCanalyser="FILTERED_${Sample}"

publicPathForCCanalyser="${PublicPath}/FILTERED"
JamesUrlForCCanalyser="${JamesUrl}/FILTERED"

CCscriptname="${captureScript}NoduplFilter.pl"

runCCanalyser
doQuotaTesting

################################################################
# Updating the public folder with analysis log files..

# to create file named ${Sample}_description.html - and link it to each of the tracks.

subfolder="FILTERED"
updateCCanalyserDataHub


if [[ ${saveDpnGenome} -eq "0" ]] ; then
  rm -f "genome_dpnII_coordinates.txt"  
fi

# Generating combined data hub

sampleForCCanalyser="${Sample}"
publicPathForCCanalyser="${PublicPath}"
JamesUrlForCCanalyser="${JamesUrl}"

generateCombinedDataHub

# Cleaning up after ourselves ..

cleanUpRunFolder
makeSymbolicLinks

# Data hub address (print to stdout) ..
updateHub_part3final

echo
echo "All done !"
echo  >> "/dev/stderr"
echo "All done !" >> "/dev/stderr"

# Copying log files

echo "Copying run log files.." >> "/dev/stderr"

cp -f ./qsub.out "${PublicPath}/${Sample}_logFiles/${Sample}_qsub.out"
cp -f ./qsub.err "${PublicPath}/${Sample}_logFiles/${Sample}_qsub.err"

echo "Log files copied !" >> "/dev/stderr"

exit 0