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

doTrackExist(){
    # NEEDS THESE TO BE SET BEFORE CALL :
    #trackName=""
     
    if [ -s "${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt" ]; then
    
    echo -e "grep bigDataUrl ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt | grep -c \"${fileName}\$\" " > temp.command
    chmod u=rwx temp.command
    trackExists=$(( $(./temp.command) ))
    rm -f temp.command
    
    else
    trackExists=0
    
    fi
}

doMultiWigParent(){
    
    # NEEDS THESE TO BE SET BEFORE CALL :
    #longLabel=""
    #trackName=""
    #overlayType=""
    #windowingFunction=""
    #visibility=""
    
    echo "" >> TEMP2_tracks.txt
    echo "#--------------------------------------" >> TEMP2_tracks.txt
    echo "" >> TEMP2_tracks.txt
    
    echo "track ${trackName}" >> TEMP2_tracks.txt
    echo "container multiWig" >> TEMP2_tracks.txt
    echo "shortLabel ${trackName}" >> TEMP2_tracks.txt
    echo "longLabel ${longLabel}" >> TEMP2_tracks.txt
    echo "type bigWig" >> TEMP2_tracks.txt
    echo "visibility ${visibility}" >> TEMP2_tracks.txt
    echo "aggregate ${overlayType}" >> TEMP2_tracks.txt
    echo "showSubtrackColorOnUi on" >> TEMP2_tracks.txt
    #echo "windowingFunction maximum" >> TEMP2_tracks.txt
    #echo "windowingFunction mean" >> TEMP2_tracks.txt
    echo "windowingFunction ${windowingFunction}" >> TEMP2_tracks.txt
    echo "configurable on" >> TEMP2_tracks.txt
    echo "dragAndDrop subtracks" >> TEMP2_tracks.txt
    echo "autoScale on" >> TEMP2_tracks.txt
    echo "alwaysZero on" >> TEMP2_tracks.txt
    echo "" >> TEMP2_tracks.txt
    
}

doMultiWigChild(){
    
    # NEEDS THESE TO BE SET BEFORE CALL
    # parentTrack=""
    # trackName=""
    # fileName=".bw"
    # trackColor=""
    # trackPriority=""
    # bigWigSubfolder="${PublicPath}/FILTERED"
    
    # Does this track have data file which has non-zero size?
    if [ -s "${PublicPath}/${bigWigSubfolder}/${fileName}" ]; then
    
    echo "track ${trackName}" >> TEMP2_tracks.txt
    echo "parent ${parentTrack}" >> TEMP2_tracks.txt
    echo "bigDataUrl ${ServerAndPath}/${bigWigSubfolder}/${fileName}" >> TEMP2_tracks.txt
    # These are super long paths. using relative paths instead !
    #echo "bigDataUrl ${fileName}" >> TEMP2_tracks.txt
    echo "shortLabel ${trackName}" >> TEMP2_tracks.txt
    echo "longLabel ${trackName}" >> TEMP2_tracks.txt
    echo "type bigWig" >> TEMP2_tracks.txt
    echo "color ${trackColor}" >> TEMP2_tracks.txt
    echo "html http://${JamesUrl}/${Sample}_${CCversion}_description" >> TEMP2_tracks.txt
    echo "priority ${trackPriority}" >> TEMP2_tracks.txt
    echo "" >> TEMP2_tracks.txt
    
    else
    
    echo "Cannot find track ${PublicPath}/${bigWigSubfolder}/${fileName} - not writing it into ${parentTrack} track "  >> "/dev/stderr"
    
    fi
}

doRegularTrack(){
    
    # NEEDS THESE TO BE SET BEFORE CALL
    # trackName=""
    # longLabel=""
    # fileName=".bw"
    # trackColor=""
    # trackPriority=""
    # visibility=""
    # trackType="bb" "bw"
   
    # Is this track already written to the tracks.txt file?
    doTrackExist
    if [ "${trackExists}" -eq 0 ] ; then
   
    # Does this track have data file which has non-zero size?
    if [ -s "${publicPathForCCanalyser}/${fileName}" ] ; then

    echo "" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "#--------------------------------------" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    
    echo "track ${trackName}" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    # These are super long paths. using relative paths instead !
    #echo "bigDataUrl ${ServerAndPath}/${bigWigSubfolder}/${fileName}" | sed 's/\/\//\//g' >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "bigDataUrl ${fileName}"  >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "shortLabel ${trackName}" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "longLabel ${longLabel}" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    
    if [ "${trackType}" = "bb" ] ; then
    # This is 9-column bed file (last column is color)
    echo "type bigBed" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    #echo "itemRgb on" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    # Defaults to "bw"
    else
    echo "type bigWig" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    #echo "color ${trackColor}" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    fi
    
    echo "color ${trackColor}" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "visibility ${visibility}" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "priority ${trackPriority}" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "autoScale on" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "alwaysZero on" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    echo "" >> ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt
    
    else
        echo "TRACK DESCRIPTION NOT CREATED - track ${trackName} does not have size in ${publicPathForCCanalyser}/${fileName}"
    fi
    else
        echo "TRACK DESCRIPTION NOT CREATED - track ${trackName} does not exist in ${publicPathForCCanalyser}/${fileName}"
    fi
    
}

copyPreCCanalyserLogFilesToPublic(){
    
# Making a public folder for log files
printThis="Making a public folder for log files"
printToLogFile
mkdir -p "${PublicPath}/${Sample}_logFiles"

# Copying log files
printThis="Copying log files to public folder"
printToLogFile
cp -rf READ1_fastqc_ORIGINAL "${PublicPath}/${Sample}_logFiles"
cp -rf READ2_fastqc_ORIGINAL "${PublicPath}/${Sample}_logFiles"
cp -rf READ1_fastqc_TRIMMED "${PublicPath}/${Sample}_logFiles"
cp -rf READ2_fastqc_TRIMMED "${PublicPath}/${Sample}_logFiles"

cp -rf "Combined_reads_fastqc" "${PublicPath}/${Sample}_logFiles"

cp -f ./read_trimming.log "${PublicPath}/${Sample}_logFiles/${Sample}_read_trimming.log"
cp -f ./flashing.log "${PublicPath}/${Sample}_logFiles/${Sample}_flashing.log"
cp -f ./out.hist "${PublicPath}/${Sample}_logFiles/${Sample}_flash.hist"
    
}


# The updateHub_partxx scripts are to make the puzzle of making 3 hubs a little more consistent :
# 1) RAW ccanalyser output hub and its metadata
# 2) FILTERED ccanalyser output hub and its metadata
# 3) RAW + FILTERED ccanalyser output hub and its combined metadata

updateHub_part1(){

printThis="Writing the description html-document"
printToLogFile

# Write the beginning of the html file

    echo "<!DOCTYPE HTML PUBLIC -//W3C//DTD HTML 4.01//EN" > begin.html
    echo "http://www.w3.org/TR/html4/strict.dtd" >> begin.html
    echo ">" >> begin.html
    echo " <html lang=en>" >> begin.html
    echo " <head>" >> begin.html
    echo " <title> ${hubNameList[0]} data hub in ${genomeName} </title>" >> begin.html
    echo " </head>" >> begin.html
    echo " <body>" >> begin.html

    # Generating TimeStamp 
    TimeStamp=($( date | sed 's/[: ]/_/g' ))
    DateTime="$(date)"
    
    echo "<p>Data produced ${DateTime} with CapC pipeline (coded by James Davies, pipelined by Jelena Telenius, located in ${CapturePipePath} )</p>" > temp_description.html
    
    echo "<hr />" >> temp_description.html
    
    echo "Oligo coordinates given to the run :" >> temp_description.html
    echo "<pre>" >> temp_description.html
    cat ${OligoFile} | cut -f 1-4 | awk '{print $1"\tchr"$2"\t"$3"\t"$4}' >> temp_description.html
    echo "</pre>" >> temp_description.html
    
    echo "<hr />" >> temp_description.html
    
#    echo "<p>User manual - to understand the pipeline and the output :  <a href=\"http://sara.molbiol.ox.ac.uk/public/jdavies/MANUAL_for_pipe/PipeUserManual.pdf\" >CapturePipeUserManual.pdf</a></p>" >> temp_description.html
    
    echo "<hr />" >> temp_description.html
    
    echo "<p>Data located in : $(pwd)</p>" >> temp_description.html
    echo "<p>Sample name : ${Sample}, containing fastq files : ${Read1} and ${Read2}</p>" >> temp_description.html

    echo "<li>Run log files available in : <a href=\"${ServerAndPath}/${Sample}_logFiles/${Sample}_${QSUBOUTFILE}\" >${QSUBOUTFILE}</a> , and <a href=\"${ServerAndPath}/${Sample}_logFiles/${Sample}_${QSUBERRFILE}\" >${QSUBERRFILE}</a>"  >> temp_description.html
    
}

updateHub_part2a(){
    echo "<hr />" >> temp_description.html

    echo "<h4>FASTQC results here : </h4>" >> temp_description.html

    echo "<li>FastQC results (untrimmed) : <a href=\"${ServerAndPath}/${Sample}_logFiles/READ1_fastqc_ORIGINAL/fastqc_report.html\" >READ1_fastqc_ORIGINAL/fastqc_report.html</a>   , and " >> temp_description.html
    echo " <a href=\"${ServerAndPath}/${Sample}_logFiles/READ2_fastqc_ORIGINAL/fastqc_report.html\" >READ2_fastqc_ORIGINAL/fastqc_report.html</a>  </li>" >> temp_description.html
   
    echo "<li>FastQC results (trimmed) : <a href=\"${ServerAndPath}/${Sample}_logFiles/READ1_fastqc_TRIMMED/fastqc_report.html\" >READ1_fastqc_TRIMMED/fastqc_report.html</a>   , and " >> temp_description.html
    echo " <a href=\"${ServerAndPath}/${Sample}_logFiles/READ2_fastqc_TRIMMED/fastqc_report.html\" >READ2_fastqc_TRIMMED/fastqc_report.html</a>  </li>" >> temp_description.html 
  
    echo "<li>FastQC results (flashed, combined) : <a href=\"${ServerAndPath}/${Sample}_logFiles/Combined_reads_fastqc/fastqc_report.html\" >Combined_reads_fastqc/fastqc_report.html</a> </li>" >> temp_description.html 
   
    echo "<hr />" >> temp_description.html
   
    echo "<h4>Trimming/flashing log files here : </h4>" >> temp_description.html
    echo "<li>Harsh trim_galore trim : <a href=\"${ServerAndPath}/${Sample}_logFiles/${Sample}_read_trimming.log\" >read_trimming.log</a>  </li>" >> temp_description.html
    echo "<li>Flashing : <a href=\"${ServerAndPath}/${Sample}_logFiles/${Sample}_flashing.log\" >flashing.log</a>  </li>" >> temp_description.html
    echo "<li>Histogram of flashed reads : <a href=\"${ServerAndPath}/${Sample}_logFiles/${Sample}_flash.hist\" >flash.hist</a>  </li>" >> temp_description.html
   
}

updateHub_part2b(){
    
    echo "<hr />" >> temp_description.html

    echo "</body>" > end.html
    echo "</html>"  >> end.html
    
    cat begin.html temp_description.html end.html > "${sampleForCCanalyser}_description.html"
    rm -f begin.html temp_description.html end.html
    
    # Moving the description file
    mv -f "${sampleForCCanalyser}_description.html" "${publicPathForCCanalyser}/."
   
}

updateHub_part2c(){
    
    # Link the file to each of the existing tracks..
    seddedUrl=$( echo ${JamesUrl} | sed 's/\//\\\//g' )
    echo "sed -i 's/alwaysZero on/alwaysZero on\nhtml http\:\/\/${seddedUrl}\/${Sample}_description/' ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_tracks.txt " > temp.command

    chmod u=rwx temp.command
    cat temp.command
    ./temp.command
    rm -f temp.command
    
}

updateHub_part3(){
    TEMPname=$( echo ${sampleForCCanalyser} | sed 's/_.*//' )
    echo
    if [ "${TEMPname}" == "RAW" ] || [ "${TEMPname}" == "PREfiltered" ] || [ "${TEMPname}" == "FILTERED" ] || [ "${TEMPname}" == "COMBINED" ] ; then
    echo "Generated a data hub in : ${ServerAndPath}/${TEMPname}/${sampleForCCanalyser}_${CCversion}_hub.txt"
    else
    echo "Generated a data hub in : ${ServerAndPath}/${sampleForCCanalyser}_${CCversion}_hub.txt"
    fi
    echo 'How to load this hub to UCSC : http://sara.molbiol.ox.ac.uk/public/telenius/DataHubs/ReadMe/HowToUseA_DataHUB_160813.pdf'    

}

updateHub_part3final(){
    echo
    echo "Generated a data hub for RAW data in : ${ServerAndPath}/RAW/RAW_${Sample}_${CCversion}_hub.txt"
    echo "Generated a data hub for FILTERED data in : ${ServerAndPath}/FILTERED/FILTERED_${Sample}_${CCversion}_hub.txt"
    echo
    echo "Generated a COMBINED data hub in : ${ServerAndPath}/${Sample}_${CCversion}_hub.txt"
    echo 'How to load this hub to UCSC : http://sara.molbiol.ox.ac.uk/public/telenius/DataHubs/ReadMe/HowToUseA_DataHUB_160813.pdf'    

}

updateCCanalyserDataHub(){
    
printThis="Updating the public folder with analysis log files.."
printToLogFile

temptime=$( date +%d%m%y )

mkdir -p ${publicPathForCCanalyser}/${sampleForCCanalyser}_logFiles

#samForCCanalyser="F1_${Sample}_pre${CCversion}/Combined_reads_REdig.sam"
samBasename=$( echo ${samForCCanalyser} | sed 's/.*\///' | sed 's/\.sam$//' )

cp -f "${sampleForCCanalyser}_${CCversion}/${samBasename}_report_${CCversion}.txt" "${publicPathForCCanalyser}/${sampleForCCanalyser}_logFiles/."
#cp -f "${sampleForCCanalyser}_${CCversion}/${samBasename}_coordstring_${CCversion}.txt" "${publicPathForCCanalyser}/${sampleForCCanalyser}_logFiles/."
    
# Make the bigbed file from the bed file of oligo coordinates and used exlusions ..

tail -n +2 "${OligoFile}" | sort -k1,1 -k2,2n > tempBed.bed
bedOrigName=$( echo "${OligoFile}" | sed 's/\..*//' | sed 's/.*\///' )
bedname=$( echo "${OligoFile}" | sed 's/\..*//' | sed 's/.*\///' | sed 's/^/'${Sample}'_/' )

# Oligo coordinates 
tail -n +2 "${sampleForCCanalyser}_${CCversion}/${bedOrigName}.bed" | awk 'NR%2==1' | sort -k1,1 -k2,2n > tempBed.bed
bedToBigBed -type=bed9 tempBed.bed ${ucscBuild} "${sampleForCCanalyser}_${CCversion}/${bedname}_oligo.bb"
rm -f tempBed.bed

# Exclusion fragments
tail -n +2 "${sampleForCCanalyser}_${CCversion}/${bedOrigName}.bed" | awk 'NR%2==0' | sort -k1,1 -k2,2n > tempBed.bed
bedToBigBed -type=bed9 tempBed.bed ${ucscBuild} "${sampleForCCanalyser}_${CCversion}/${bedname}_exclusion.bb"
rm -f tempBed.bed

mv -f "${sampleForCCanalyser}_${CCversion}/${bedname}_oligo.bb" ${publicPathForCCanalyser}
mv -f "${sampleForCCanalyser}_${CCversion}/${bedname}_exclusion.bb" ${publicPathForCCanalyser}

    fileName=$( echo ${publicPathForCCanalyser}/${bedname}_oligo.bb | sed 's/^.*\///' )
    trackName=$( echo ${fileName} | sed 's/\.bb$//' )
    longLabel="${trackName}_coordinates"
    trackColor="133,0,122"
    trackPriority="1"
    visibility="full"
    trackType="bb"
    
    doRegularTrack
    
    fileName=$( echo ${publicPathForCCanalyser}/${bedname}_exclusion.bb | sed 's/^.*\///' )
    trackName=$( echo ${fileName} | sed 's/\.bb$//' )
    longLabel="${trackName}_coordinates"
    trackColor="133,0,0"
    trackPriority="2"
    visibility="full"
    trackType="bb"
    
    doRegularTrack

    
# Add the missing tracks - if the hub was not generated properly in the perl..
    
for file in ${publicPathForCCanalyser}/*.bw
do
    fileName=$( echo ${file} | sed 's/^.*\///' )
    trackName=$( echo ${fileName} | sed 's/\.bw$//' )
    longLabel=${trackName}
    trackColor="0,0,0"
    trackPriority="200"
    visibility="hide"
    trackType="bw"
    bigWigSubfolder=${bigWigSubfolder}
    
    doRegularTrack
    
done

    updateHub_part2c

echo
cat "${runDir}/${sampleForCCanalyser}_${CCversion}/${samBasename}_report_${CCversion}.txt"

    updateHub_part3 
    
}

generateCombinedDataHub(){
    
printThis="Updating the public folder with analysis log files.."
printToLogFile

temptime=$( date +%d%m%y )

# Here add :

# Generate the hub itself, as well as genomes.txt

#${publicPathForCCanalyser}/${Sample}_${CCversion}_hub.txt

# cat MES0_CC2_hub.txt
#hub MES0_CC2
#shortLabel MES0_CC2
#longLabel MES0_CC2_CaptureC
#genomesFile http://userweb.molbiol.ox.ac.uk/public/mgosden/Dilut_Cap/MES0_CC2_genomes.txt
#email james.davies@trinity.ox.ac.uk

echo "hub ${Sample}_${CCversion}" > ${PublicPath}/${Sample}_${CCversion}_hub.txt
echo "shortLabel ${Sample}_${CCversion}" >> ${PublicPath}/${Sample}_${CCversion}_hub.txt
echo "longLabel ${Sample}_${CCversion}_CaptureC" >> ${PublicPath}/${Sample}_${CCversion}_hub.txt
echo "genomesFile ${ServerAndPath}/${Sample}_${CCversion}_genomes.txt" >> ${PublicPath}/${Sample}_${CCversion}_hub.txt
echo "email jelena.telenius@gmail.com" >> ${PublicPath}/${Sample}_${CCversion}_hub.txt

#${publicPathForCCanalyser}/${Sample}_${CCversion}_genomes.txt

# cat MES0_CC2_genomes.txt 
#genome mm9
#trackDb http://sara.molbiol.ox.ac.uk/public/mgosden/Dilut_Cap//MES0_CC2_tracks.txt

#echo "genome ${GENOME}" > ${ServerAndPath}/${Sample}_${CCversion}_genomes.txt
#echo "trackDb ${ServerAndPath}/${Sample}_${CCversion}_tracks.txt" >> ${ServerAndPath}/${Sample}_${CCversion}_genomes.txt

echo "genome ${GENOME}" > TEMP_genomes.txt
echo "trackDb ${ServerAndPath}/${Sample}_${CCversion}_tracks.txt" >> TEMP_genomes.txt
mv -f TEMP_genomes.txt ${PublicPath}/${Sample}_${CCversion}_genomes.txt

# Catenate the tracks.txt files to form new tracks.txt
cat ${PublicPath}/RAW/RAW_${Sample}_${CCversion}_tracks.txt ${PublicPath}/FILTERED/FILTERED_${Sample}_${CCversion}_tracks.txt > TEMP_tracks.txt

# Make proper redgreen tracks based on the RAW and FILTERED tracks..

#doMultiWigParent    
    # NEEDS THESE TO BE SET BEFORE CALL :
    #longLabel=""
    #trackName=""
    #overlayType=""
    #windowingFunction=""
    #visibility=""
    
#doMultiWigChild   
    # NEEDS THESE TO BE SET BEFORE CALL
    # parentTrack=""
    # trackName=""
    # fileName=".bw"
    # trackColor=""
    # trackPriority=""
    
  rm -f TEMP2_tracks.txt
    
 trackList=$( cat TEMP_tracks.txt | grep track | grep RAW | sed 's/^track RAW_//' )
 filenameList=$( cat TEMP_tracks.txt | grep bigDataUrl | grep RAW | sed 's/^bigDataUrl .*RAW\///' )
 
 cat TEMP_tracks.txt | grep track | grep RAW | sed 's/^track RAW_//' | sed 's/^track win_RAW_/win_/' > TEMP_trackList.txt
 cat TEMP_tracks.txt | grep bigDataUrl | grep RAW | sed 's/^bigDataUrl .*RAW\///' > TEMP_bigDataUrlList.txt
 
 list=$( paste TEMP_trackList.txt TEMP_bigDataUrlList.txt | sed 's/\s/,/' )
 echo list
 
 rm -f TEMP_trackList.txt TEMP_bigDataUrlList.txt
 
  
 for track in $list
 do
    echo $track
    
    trackname=$( echo $track | sed 's/,.*//' )
    filename=$( echo $track | sed 's/.*,//')
    
    longLabel="CC_${trackname} all mapped reads RED, filtered reads GREEN"
    trackName="${trackname}"
    overlayType="solidOverlay"
    windowingFunction="maximum"
    visibility="full"
    doMultiWigParent
    
    parentTrack="${trackname}"
    trackName="${trackname}_raw"
    fileName="${filename}"
    bigWigSubfolder="RAW"
    trackColor="255,0,0"
    trackPriority="100"
    doMultiWigChild
    
 done

 
 cat TEMP_tracks.txt | grep track | grep FILTERED  | sed 's/^track FILTERED_//' | sed 's/^track win_FILTERED_/win_/' > TEMP_trackList.txt
 cat TEMP_tracks.txt | grep bigDataUrl | grep FILTERED | sed 's/^bigDataUrl .*FILTERED\///' > TEMP_bigDataUrlList.txt
 
 list=$( paste TEMP_trackList.txt TEMP_bigDataUrlList.txt | sed 's/\s/,/' )
 
 rm -f TEMP_trackList.txt TEMP_bigDataUrlList.txt
 rm -f TEMP_tracks.txt

 
 for track in $list
 do
    echo $track
    
    trackname=$( echo $track | sed 's/,.*//')
    filename=$( echo $track | sed 's/.*,//')
    
    parentTrack="${trackname}"
    trackName="${trackname}_filtered"
    fileName="${filename}"
    bigWigSubfolder="FILTERED"
    trackColor="0,200,0"
    trackPriority="110"
    doMultiWigChild
    
 done
    
    # Adding back the bigbed tracks for oligos :
    
    cat ${PublicPath}/FILTERED/FILTERED_${Sample}_${CCversion}_tracks.txt | grep -A 10 "track\s\s*${bedname}" | sed 's/^--*$/\n#################\n/' > TEMP3_preFix_tracks.txt
    
    # The bigwig paths were RELATIVE paths, and description html paths were COMPLETE paths, so we need to meddle with it a little :D
    
    #                           | bigdataurl redirect                        | no duplications in the html description path (which will be added later)
    cat TEMP3_preFix_tracks.txt | sed 's/bigDataUrl /bigDataUrl FILTERED\//' | grep -v "^html" > TEMP3_tracks.txt
    
    echo "#################" > TEMP_begin.txt
    
    cat TEMP2_tracks.txt TEMP_begin.txt TEMP3_tracks.txt > TEMP4_tracks.txt
    rm -f TEMP2_tracks.txt TEMP_begin.txt TEMP3_tracks.txt TEMP3_preFix_tracks.txt
    
    # Move over..
    
    mv -f TEMP4_tracks.txt ${PublicPath}/${Sample}_${CCversion}_tracks.txt
    
    
    
    # Adding the bigbed track for BLAT-filter-marked RE-fragments :

    cat filteringLogFor_RAW_${Sample}_${CCversion}/BlatPloidyFilterRun/BLAT_PLOIDY_FILTERED_OUTPUT/blatFilterMarkedREfragments.bed | sort -k1,1 -k2,2n > tempBed.bed
    bedToBigBed -type=bed4 tempBed.bed ${ucscBuild} ${sampleForCCanalyser}_${CCversion}_blatFilterMarkedREfragments.bb
    rm -f tempBed.bed
    
    mv -f ${sampleForCCanalyser}_${CCversion}_blatFilterMarkedREfragments.bb ${publicPathForCCanalyser}

    fileName=$( echo ${publicPathForCCanalyser}/${sampleForCCanalyser}_${CCversion}_blatFilterMarkedREfragments.bb | sed 's/^.*\///' )
    trackName=$( echo ${fileName} | sed 's/\.bb$//' )
    longLabel="${trackName}"
    trackColor="133,0,122"
    trackPriority="1"
    visibility="full"
    trackType="bb"
    bigWigSubfolder=""
    
    doRegularTrack
    
    
    
    updateHub_part1

# These have to be listed for both runs (RAW and FILTERED)
    
    echo "<li>RAW reads Capture script log file available in : <a href=\"${ServerAndPath}/RAW/RAW_${Sample}_logFiles/${RAWsamBasename}_report_${CCversion}.txt\" >RAW_${samBasename}_report_${CCversion}.txt</a> "  >> temp_description.html
    #echo "<li>RAW reads Capture script coordinate string : <a href=\"${ServerAndPath}/RAW_${sampleForCCanalyser}_logFiles/${samBasename}_coordstring_${CCversion}.txt\" >RAW_${samBasename}_coordstring_${CCversion}.txt</a> "  >> temp_description.html

    echo "<li>FILTERED reads Capture script log file available in : <a href=\"${ServerAndPath}/FILTERED/FILTERED_${Sample}_logFiles/${FILTEREDsamBasename}_report_${CCversion}.txt\" >FILTERED_${samBasename}_report_${CCversion}.txt</a> "  >> temp_description.html
    #echo "<li>FILTERED reads Capture script coordinate string : <a href=\"${ServerAndPath}/FILTERED_${sampleForCCanalyser}_logFiles/${samBasename}_coordstring_${CCversion}.txt\" >FILTERED_${samBasename}_coordstring_${CCversion}.txt</a> "  >> temp_description.html
    
    updateHub_part2a
    updateHub_part2b
    updateHub_part2c
    
    updateHub_part3 
    
}

oneFolderSymLinks(){

# ${symLinkFolderToBe}

cd ${symLinkFolderToBe}

ls | grep ".bw$"
echo "mv -f *.bw ${BigwigsAreHere}/${symLinkFolderToBe}/."
mv -f *.bw ${BigwigsAreHere}/${symLinkFolderToBe}/.

echo "ln -s ${BigwigsAreHere}/${symLinkFolderToBe}/*.bw ."
ln -s ${BigwigsAreHere}/${symLinkFolderToBe}/*.bw .

cd ..   
    
}

makeSymbolicLinks(){
    
# Move bigwigs and generate symbolic links

printThis="Moving bigwigs and generating symbolic links.."
printToLogFile

RunDir=$( pwd )

mkdir PERMANENT_BIGWIGS_do_not_move
cd PERMANENT_BIGWIGS_do_not_move
mkdir RAW FILTERED
BigwigsAreHere=$( pwd )

cd ${PublicPath}

symLinkFolderToBe="RAW"
oneFolderSymLinks

symLinkFolderToBe="FILTERED"
oneFolderSymLinks

cd ${RunDir}
    
    
}