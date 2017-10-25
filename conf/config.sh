#!/bin/bash

setConfigLocations(){

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

# The structure of the pipeline codes : 

# You should have these files, in these subfolders :
#
# CCseqBasic3/
#
# |
# |-- CCseqBasic3.sh
# |
# |-- bin
# |   |
# |   |-- runscripts
# |   |   |
# |   |   |-- CCanalyser3_noduplFilter.pl
# |   |   |-- CCanalyser3.pl
# |   |   |-- dpngenome3_1.pl
# |   |   |-- dpnII2E.pl
# |   |   |
# |   |   `-- filterArtifactMappers
# |   |       |
# |   |       |-- 1_blat.sh
# |   |       |-- 2_psl_parser.pl
# |   |       `-- filter.sh
# |   |   
# |   `-- subroutines
# |       |-- cleaners.sh
# |       |-- hubbers.sh
# |       |-- parametersetters.sh
# |       |-- runtools.sh
# |       |-- testers_and_loggers.sh
# |       `-- usageAndVersion.sh
# |
# |-- conf
# |   |-- config.sh
# |   | 
# |   |-- BLACKLIST
# |   |   |-- hg18.bed
# |   |   |-- hg19.bed
# |   |   |-- mm10.bed
# |   |   `-- mm9.bed
# |   | 
# |   `-- UCSCgenomeSizes
# |       |-- danRer10.chrom.sizes
# |       |-- danRer7.chrom.sizes
# |       |-- dm3.chrom.sizes
# |       |-- galGal4.chrom.sizes
# |       |-- hg18.chrom.sizes
# |       |-- hg19.chrom.sizes
# |       |-- hg38.chrom.sizes
# |       |-- mm10.chrom.sizes
# |       `-- mm9.chrom.sizes
# |
# `-- README
#     |-- LICENSE.txt
#     `-- README.txt



# You can add CCseqBasic3.sh to your path, to run the pipeline with command 'CCseqBasic3.sh'
# , but you can run it with /full/path/to/CCseqBasic3.sh just as well.

# All the scripts it uses to run the pipeline are in the 'bin' folder. These need not to be in the path.
# The Gnu public license and readme of the pipeline are available in the 'README' folder

# #############################################################################

# This is the CONFIGURATION FILE ( conf/config.sh )

# Fill the locations of :

# - bowtie 1 indices , whole genome fasta files , ucsc chromosome size files, blacklisted regions bed files.
# - genome digest files
# - public server address 
# - bioinformatics tools (tool paths)

# As given in below examples

# #############################################################################
# SUPPORTED GENOMES 
# #############################################################################

# Add and remove genomes via this list.
# If user tries to use another genome (not listed here), the run is aborted with "genome not supported" message.

supportedGenomes[0]="mm9"
supportedGenomes[1]="mm10"
supportedGenomes[2]="hg18"
supportedGenomes[3]="hg19"
supportedGenomes[4]="hg38"
supportedGenomes[5]="danRer7"
supportedGenomes[6]="danRer10"
supportedGenomes[7]="galGal4"
supportedGenomes[8]="dm3"
supportedGenomes[9]="dm6"
supportedGenomes[10]="mm10balb"

# The above genomes should have :
# 1) bowtie1 indices
# 2) UCSC genome sizes
# 3) genome digest files for dpnII and nlaIII (optional - but makes runs faster).
#     These can be produced with the CCseqBasic3.sh pipeline during a regular run, with flag --saveGenomeDigest
# 4) List of blacklisted regions (optional, but recommended)

# Fill these below !



# #############################################################################
# BOWTIE 1 INDICES
# #############################################################################

# These are the bowtie1 indices, built with an UCSC genome fasta (not ENSEMBLE coordinates)
# These need to correspond to the UCSC chromosome sizes files (below)

# You can build these indices with 'bowtie-build' tool of the bowtie package :
# http://bowtie-bio.sourceforge.net/manual.shtml#the-bowtie-build-indexer

# These can be symbolic links to the central copies of the indices.
# By default these are 

BOWTIE1[0]="/databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/BowtieIndex/genome"
# ls -lht /databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/BowtieIndex/      
# -rw-rw-r-- 1 manager staff 2.6G Mar 16  2012 genome.fa
# -rw-rw-r-- 1 manager staff 611M Mar 16  2012 genome.4.ebwt
# -rw-rw-r-- 1 manager staff 702M Mar 16  2012 genome.rev.1.ebwt
# -rw-rw-r-- 1 manager staff 702M Mar 16  2012 genome.1.ebwt
# -rw-rw-r-- 1 manager staff 5.8K Mar 16  2012 genome.3.ebwt
# -rw-rw-r-- 1 manager staff 306M Mar 16  2012 genome.rev.2.ebwt
# -rw-rw-r-- 1 manager staff 306M Mar 16  2012 genome.2.ebwt

BOWTIE1[1]="/databank/igenomes/Mus_musculus/UCSC/mm10/Sequence/BowtieIndex/genome"
BOWTIE1[2]="/databank/igenomes/Homo_sapiens/UCSC/hg18/Sequence/BowtieIndex/genome"
BOWTIE1[3]="/databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/BowtieIndex/genome"
BOWTIE1[4]="/databank/igenomes/Homo_sapiens/UCSC/hg38/Sequence/BowtieIndex/genome"
BOWTIE1[5]="/databank/igenomes/Danio_rerio/UCSC/danRer7/Sequence/BowtieIndex/genome"
BOWTIE1[6]="/databank/igenomes/Danio_rerio/UCSC/danRer10/Sequence/BowtieIndex/genome"
BOWTIE1[7]="/databank/igenomes/Gallus_gallus/UCSC/galGal4/Sequence/BowtieIndex/genome"
BOWTIE1[8]="/databank/igenomes/Drosophila_melanogaster/UCSC/dm3/Sequence/BowtieIndex/genome"
BOWTIE1[9]="/databank/igenomes/Drosophila_melanogaster/UCSC/dm6/Sequence/BowtieIndex/genome"
BOWTIE1[10]="/t1-data/user/rbeagrie/genomes/balbc/mm10_BALB-cJ_snpsonly/bowtie1-indexes/mm10_BALB-cJ"

# The indices in the BOWTIE1 array refer to genome names in supportedGenomes array (top of page).

# Not all of them need to exist : only the ones you will be using.
# The pipeline checks that at least one index file exists, before proceeding with the analysis.

# When adding new genomes : remember to update the "supportedGenomes" list above as well !

# To add NEW genomes (in addition to above) to the list - modify also the subroutine
# setBOWTIEgenomeSizes() in the main script CCseqBasic3.sh


# #############################################################################
# BOWTIE 2 INDICES
# #############################################################################

# These are the bowtie2 indices, built with an UCSC genome fasta (not ENSEMBLE coordinates)
# These need to correspond to the UCSC chromosome sizes files (below)

# You can build these indices with 'bowtie-build' tool of the bowtie2 package :
# http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#the-bowtie2-build-indexer

# These can be symbolic links to the central copies of the indices.
# By default these are 

BOWTIE2[0]="/databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/Bowtie2Index/genome"

# ls -lht /databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/Bowtie2Index
# -rw-rw-r-- 1 manager staff 2.6G Mar 16  2012 genome.fa
# -rw-rw-r-- 1 manager staff 611M Apr 10  2012 genome.2.bt2
# -rw-rw-r-- 1 manager staff 611M Apr 10  2012 genome.4.bt2
# -rw-rw-r-- 1 manager staff 818M Apr 10  2012 genome.rev.1.bt2
# -rw-rw-r-- 1 manager staff 611M Apr 10  2012 genome.rev.2.bt2
# -rw-rw-r-- 1 manager staff 818M Apr 10  2012 genome.1.bt2
# -rw-rw-r-- 1 manager staff 5.8K Apr 10  2012 genome.3.bt2

BOWTIE2[1]="/databank/igenomes/Mus_musculus/UCSC/mm10/Sequence/Bowtie2Index/genome"
BOWTIE2[2]="/databank/igenomes/Homo_sapiens/UCSC/hg18/Sequence/Bowtie2Index/genome"
BOWTIE2[3]="/databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome"
BOWTIE2[4]="/databank/igenomes/Homo_sapiens/UCSC/hg38/Sequence/Bowtie2Index/genome"
BOWTIE2[5]="/databank/igenomes/Danio_rerio/UCSC/danRer7/Sequence/Bowtie2Index/genome"
BOWTIE2[6]="/databank/igenomes/Danio_rerio/UCSC/danRer10/Sequence/Bowtie2Index/genome"
BOWTIE2[7]="/databank/igenomes/Gallus_gallus/UCSC/galGal4/Sequence/Bowtie2Index/genome"
BOWTIE2[8]="/databank/igenomes/Drosophila_melanogaster/UCSC/dm3/Sequence/Bowtie2Index/genome"
BOWTIE2[9]="/databank/igenomes/Drosophila_melanogaster/UCSC/dm6/Sequence/Bowtie2Index/genome"
BOWTIE2[10]="/t1-data/user/rbeagrie/genomes/balbc/mm10_BALB-cJ_snpsonly/bowtie2-indexes/mm10_BALB-cJ"

# The indices in the BOWTIE2 array refer to genome names in supportedGenomes array (top of page).

# Not all of them need to exist : only the ones you will be using.
# The pipeline checks that at least one index file exists, before proceeding with the analysis.

# When adding new genomes : remember to update the "supportedGenomes" list above (top of this file) as well !


# #############################################################################
# WHOLE GENOME FASTA FILES
# #############################################################################

# These are the whole genome fasta files, against which the bowtie1 indices were built, in UCSC coordinate set (not ENSEMBLE coordinates)
# These need to correspond to the UCSC chromosome sizes files (below)

# These can be symbolic links to the central copies of the indices.
# By default these are 

WholeGenomeFASTA[0]="/databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[1]="/databank/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[2]="/databank/igenomes/Homo_sapiens/UCSC/hg18/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[3]="/databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[4]="/databank/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[5]="/databank/igenomes/Danio_rerio/UCSC/danRer7/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[6]="/databank/igenomes/Danio_rerio/UCSC/danRer10/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[7]="/databank/igenomes/Gallus_gallus/UCSC/galGal4/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[8]="/databank/igenomes/Drosophila_melanogaster/UCSC/dm3/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[9]="/databank/igenomes/Drosophila_melanogaster/UCSC/dm6/Sequence/WholeGenomeFasta/genome.fa"
WholeGenomeFASTA[10]="/t1-data/user/rbeagrie/genomes/balbc/mm10_BALB-cJ_snpsonly/mm10_BALB-cJ.fa"

# The indices in the WholeGenomeFASTA array refer to genome names in supportedGenomes array (top of page).

# Not all of them need to exist : only the ones you will be using.
# The pipeline checks that this file exists, before proceeding with the analysis.

# When adding new genomes : remember to update the "supportedGenomes" list above as well !

# #############################################################################
# UCSC GENOME SIZES
# #############################################################################

# The UCSC genome sizes, for ucsctools .
# By default these are located in the 'conf/UCSCgenomeSizes' folder (relative to location of CCseqBasic3.sh main script) .
# All these are already there - they come with the CCseqBasic4 codes.

# Change the files / paths below, if you want to use your own versions of these files. 

# These can be fetched with ucsctools :
# module load ucsctools
# fetchChromSizes mm9 > mm9.chrom.sizes

UCSC[0]="${confFolder}/UCSCgenomeSizes/mm9.chrom.sizes"
UCSC[1]="${confFolder}/UCSCgenomeSizes/mm10.chrom.sizes"
UCSC[2]="${confFolder}/UCSCgenomeSizes/hg18.chrom.sizes"
UCSC[3]="${confFolder}/UCSCgenomeSizes/hg19.chrom.sizes"
UCSC[4]="${confFolder}/UCSCgenomeSizes/hg38.chrom.sizes"
UCSC[5]="${confFolder}/UCSCgenomeSizes/danRer7.chrom.sizes"
UCSC[6]="${confFolder}/UCSCgenomeSizes/danRer10.chrom.sizes"
UCSC[7]="${confFolder}/UCSCgenomeSizes/galGal4.chrom.sizes"
UCSC[8]="${confFolder}/UCSCgenomeSizes/dm3.chrom.sizes"
UCSC[9]="${confFolder}/UCSCgenomeSizes/dm6.chrom.sizes"
UCSC[10]="${confFolder}/UCSCgenomeSizes/mm10.chrom.sizes"

# The indices in the UCSC array refer to genome names in supportedGenomes array (top of page).

# Not all of them need to exist : only the ones you will be using.
# The pipeline checks that at least one index file exists, before proceeding with the analysis

# When adding new genomes : remember to update the "supportedGenomes" list above (top of this file) as well !

# To add NEW genomes (in addition to above) to the list - modify also the subroutine
# setUCSCgenomeSizes() in the /bin/genomeSetters.sh script



# #############################################################################
# GENOME DIGEST FILES for dpnII and nlaIII (optional - but makes runs faster)
# #############################################################################

# To turn this off, set :
# CaptureDigestPath="NOT_IN_USE"

CaptureDigestPath="/home/molhaem2/telenius/CCseqBasic/digests"

# #############################################################################
# BLACKLISTED REGIONS FILES
# #############################################################################

# The blacklisted regions, for final filtering of the output files.
# These regions are the high peaks due to collapsed repeats in the genome builds,
# as well as some artifactual regions in the genome builds.
#
# The tracks given with the pipeline are :
#
# ----------------------------------------------
#
# mm9 = intra-house peak call (Jim Hughes research group) of these regions in sonication (control) sample data.
# mm10 = lift-over of the mm9 track
#
# ----------------------------------------------
#
# hg18 = duke blacklisted regions wgEncodeDukeRegionsExcluded.bed6.gz http://genome.ucsc.edu/cgi-bin/hgFileUi?db=hg18&g=wgEncodeMapability
#      Principal Investigator on grant 1       Lab producing data 2    View - Peaks or Signals 3       ENCODE Data Freeze 4    Table name at UCSC 5    Size    File Type       Additional Details
#      Crawford        Crawford - Duke University      Excludable      ENCODE Nov 2008 Freeze  wgEncodeDukeRegionsExcluded      19 KB  bed6    subId=104; labVersion=satellite_rna_chrM_500.bed.20080925;
# hg19 = duke blacklisted regions wgEncodeDukeMapabilityRegionsExcludable.bed.gz http://genome.ucsc.edu/cgi-bin/hgFileUi?db=hg19&g=wgEncodeMapability
#      PI1     Lab2    View3   Window size4    UCSC Accession5 Size    File Type       Additional Details
#      Crawford        Crawford - Duke University      Excludable              wgEncodeEH000322         17 KB  bed     dataVersion=ENCODE Mar 2012 Freeze; dateSubmitted=2011-03-28; subId=3840; labVersion=satellite_rna_chrM_500.bed.20080925; 
#
# Duke blacklisted regions are "too stringent" - they tend to filter too much, so even some good data gets filtered at times.
#
# -----------------------------------------------


# By default these are located in the 'conf/blackListedRegions' folder (relative to location of CCseqBasic3.sh main script) .
# All these are already there - they come with the CCseqBasic4 codes.

# Change the files / paths below, if you want to use your own versions of these files.

genomesWhichHaveBlacklist[0]="mm9"
genomesWhichHaveBlacklist[1]="mm10"
genomesWhichHaveBlacklist[2]="hg18"
genomesWhichHaveBlacklist[3]="hg19"
genomesWhichHaveBlacklist[4]="mm10balb"
# - i.e. : not all genomes have to have a blacklist.
# If the genome is not listed here, blacklist filtering is NOT conducted within the pipeline (turned off automatically).

# It is recommended to generate intra-house peak call for ALL GENOMES - from a control (sonication etc) data , however.
# This is not so crucial as it is for analysis of DNaseI, ATAC or ChIP-seq data, but better safe than sorry !

BLACKLIST[0]="${confFolder}/BLACKLIST/mm9.bed"
BLACKLIST[1]="${confFolder}/BLACKLIST/mm10.bed"
BLACKLIST[2]="${confFolder}/BLACKLIST/hg18.bed"
BLACKLIST[3]="${confFolder}/BLACKLIST/hg19.bed"
BLACKLIST[4]="${confFolder}/BLACKLIST/mm10.bed"

# The indices in the BLACKLIST array refer to genome names in genomesWhichHaveBlacklist array.

# ----------------------------------------------

# PUBLIC DATA - FOR UCSC VISUALISATION

# All visualisation data will be saved in a publicly available disk space
# If PIPE_hubbing.txt is used - ALL FILES are saved directly in the publicly available disk space.
# If PIPE_hubbingSymbolic.txt is used, symbolic links are generated for the bigwig files instead of storing the actual files.
#     When using PIPE_hubbingSymbolic.txt , the folder given in column 3 in PIPE_hubbingSymbolic.txt (the folder from which
#     the bigwigs are linked to the public data area),
#     needs to be WORLD-READABLE (a=r)

# The HTTP (or ftp) server address, and public data folder structure

SERVERTYPE="http"
SERVERADDRESS="userweb.molbiol.ox.ac.uk"

# These together set the server address to be :
# http://userweb.molbiol.ox.ac.uk

# If you don't set the ones below, it assumes the public data area structure looks like this :

# Disk area location :
# /public/datafile.txt

# Publicly available file in server :
# http://userweb.molbiol.ox.ac.uk/public/datafile.txt

# You can delete or add stuff from the path, to match your data area design, with these parameters :

# /public/telenius/dnasepipetests/PORTtest291216b

REMOVEfromPUBLICFILEPATH=""

# For example, your disk area location is :
# /upper/folder/public/datafile.txt

# And your publicly available file in server :
# http://userweb.molbiol.ox.ac.uk/public/datafile.txt

# To reach that, you would need to set :
# REMOVEfromPUBLICFILEPATH="/upper/folder"

ADDtoPUBLICFILEPATH=""

# For example, your disk area location is :
# /public/datafile.txt

# Publicly available file in server :
# http://userweb.molbiol.ox.ac.uk/home/folder/public/datafile.txt

# To reach that, you would need to set :
# ADDtoPUBLICFILEPATH="/home/folder"

tobeREPLACEDinPUBLICFILEPATH=""
REPLACEwithThisInPUBLICFILEPATH="" # This can be empty : then the 'tobeREPLACEDinPUBLICFILEPATH' will be replaced with '' (just removed)

# For example, your disk area location is :
# /public/sub/folder/datafile.txt

# And your publicly available file in server :
# http://userweb.molbiol.ox.ac.uk/public/another/folder/structure/datafile.txt

# To reach that, you would need to set :
# tobeREPLACEDinPUBLICFILEPATH="/sub/folder"
# REPLACEwithThisInPUBLICFILEPATH="/another/folder/structure"


# THE ORDER THE ABOVE TAKE EFFECT :

# 1) REMOVE from public path
# 2) ADD to public path
# 3) REPLACE in public path

# Note !! - the (3) is vulnerable to repeating of the same subfolder structure.
# It only will find and replace the LEFTmost of the occurrences of the file path it searches for.

# You can finetune the subroutine parsePublicLocations() which does this parsing :
# it is given in the end of this config.sh file !

# -----------------------------------------------

}

setPathsForPipe(){

# Setting the needed programs to path.

# This can be done EITHER via module system, or via EXPORTING them to the path.
# If exporting to the path - the script does not check already existing conflicting programs (which may contain executable with same names as these)

# Change this to "0" if you want to use direct paths.
useModuleSystem=1
# useModuleSystem=1 : load via module system
# useModuleSystem=0 : load via direct paths


# PATHS_LOADED_VIA_MODULES

if [ "${useModuleSystem}" -eq 1 ]; then

module purge
# Removing all already-loaded modules to start from clean table

module load samtools/1.1
# Supports all samtools versions in 1.* series. Does not support samtools/0.* .

module load bowtie/1.1.2
# Supports all bowtie1 versions 1.* and 0.*
module load bowtie2/2.1.0
# Supports all bowtie2 versions

module load bedtools/2.17.0
# Supports bedtools versions 2.1* . Does not support bedtools versions 2.2*

module load ucsctools/1.0
# Supports ucsctools versions 1.* . Not known if supports also ucsctools versions 2.* (most probably not)

module load flash/1.2.8
# Not known if would support other flash versions. Most probably will support.

module load fastqc/0.10.1
# Will not support fastqc versions 0.11.* or newer.
# CCseqBasic3 includes a legacy version of fastqc ( fastqc_v0.10.1.zip ), which you can install if you don't have "old enough" fastqc.

module load trim_galore/0.3.1
# Not known if would support other trim_galore versions. Most probably will support.

# module load cutadapt/1.2.1
# If your trim_galore module does not automatically load the needed cutadapt,
# uncomment this line

# Not known if would support other cutadapt versions. Most probably will support.

module load blat/35
# Not known if would support other blat versions. Most probably will support.

module load perl/5.18.1
# Most probably will run with any perl

module load python/2.7.5
# Most probably will run with any Python

module list


# EXPORT_PATHS_WITHOUT_MODULE_SYSTEM

else
    
# Note !!!!!
# - the script does not check already existing conflicting programs within $PATH (which may contain executable with same names as these)

export PATH=$PATH:/package/samtools/1.1/bin/samtools
export PATH=$PATH:/package/bowtie/1.1.2/bin/bowtie

export PATH=$PATH:/package/bedtools/2.17.0/bin/bedtools
export PATH=$PATH:/package/ucsctools/1.0/bin
export PATH=$PATH:/package/flash/1.2.8/bin/flash
export PATH=$PATH:/package/fastqc/0.10.1/bin/fastqc
export PATH=$PATH:/package/trim_galore/0.3.1/bin/trim_galore
export PATH=$PATH:/package/cutadapt/1.2.1/bin/cutadapt
export PATH=$PATH:/package/perl/5.18.1/bin/perl

export PATH=$PATH:/package/blat/35/bin/blat
export PATH=$PATH:/package/python/2.7.5/bin/python

# See notes of SUPPORTED VERSIONS above !

echo $PATH

fi

}


# -------------------------------------------
# The parser of server name and public file location.
# The parser is given here - to facilitate the modifications to Your Public Environment
parsePublicLocations(){

# THE ORDER THE ABOVE TAKE EFFECT :

# 1) REMOVE from public path
# 2) ADD to public path
# 3) REPLACE in public path

echo "Parse server path from disk path .."
echo "Parse server path from disk path .." >&2

echo
echo "diskFolder ${diskFolder}"
# The diskFolder is the second column of PIPE_hubbing.sh or PIPE_hubbingSymbolic.txt

serverFolderTEMP=${diskFolder}

# 1) REMOVE from public path

if [ "${REMOVEfromPUBLICFILEPATH}" != "" ];then
    
# Replace all / with \/  to be readable for SED parser
removeParseForSed=$( echo ${REMOVEfromPUBLICFILEPATH} | sed 's/\//\\\//g' )
# Remove from the beginning (^) of the disk path
removed_from_path=$( echo ${serverFolderTEMP} | sed 's/^'${removeParseForSed}'//' )
# Update the serverFolderTEMP
serverFolderTEMP=${removed_from_path}

fi

# 2) ADD to public path

if [ "${ADDtoPUBLICFILEPATH}" != "" ];then

# Replace all / with \/  to be readable for SED parser
addParseForSed=$( echo ${ADDtoPUBLICFILEPATH} | sed 's/\//\\\//g' )
# Add to the beginning (^) of the disk path
added_to_path=$( echo ${serverFolderTEMP} | sed 's/^/'${addParseForSed}'/' )
# Update the serverFolderTEMP
serverFolderTEMP=${added_to_path}

fi

# 3) REPLACE in public path

if [ "${tobeREPLACEDinPUBLICFILEPATH}" != "" ];then
    
# Replace all / with \/  to be readable for SED parser
toBeParseForSed=$( echo ${tobeREPLACEDinPUBLICFILEPATH} | sed 's/\//\\\//g' )
withThisParseForSed=$( echo ${REPLACEwithThisInPUBLICFILEPATH} | sed 's/\//\\\//g' )
# Replace within the disk path
replaced_path=$( echo ${serverFolderTEMP} | sed 's/'${toBeParseForSed}'/'${withThisParseForSed}'/' )
# Update the serverFolderTEMP
serverFolderTEMP=${replaced_path}

# Note !! - the (3) is vulnerable to repeating of the same subfolder structure.
# It only will find and replace the LEFTmost of the occurrences of the file path it searches for.

fi

# This is the value which is returned to the script :

serverFolder="${serverFolderTEMP}"

echo
echo "serverFolder ${serverFolder}"
    
}
