##########################################################################
# Copyright 2017, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
#                                                                        #
# This file is part of CCseqBasic3 .                                     #
#                                                                        #
# CCseqBasic4 is free software: you can redistribute it and/or modify    #
# it under the terms of the GNU General Public License as published by   #
# the Free Software Foundation, either version 3 of the License, or      #
# (at your option) any later version.                                    #
#                                                                        #
# CCseqBasic4 is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# GNU General Public License for more details.                           #
#                                                                        #
# You should have received a copy of the GNU General Public License      #
# along with CCseqBasic4.  If not, see <http://www.gnu.org/licenses/>.   #
##########################################################################


Installation instructions :

1) Ask Jelena (jelena __ telenius __ at __ gmail __ com) to send you the tar.gz file including the codes.

2) Unpack with this command :
    tar --preserve-permissions -xzf CCseqBasic3.tar.gz

3) Fill in the locations (or modules) of the needed tools (bowtie, fastqc etc), and the genome builds, to the config files :
    nano CCseqBasic3/conf/loadNeededTools.sh        # Instructions as comment lines in the  loadNeededTools.sh file
    nano CCseqBasic3/conf/genomeBuildSetup.sh       # Instructions as comment lines in the genomeBuildSetup.sh file

4) Fill in your server address to the conf/serverAddressAndPublicDiskSetup.sh file
    nano CCseqBasic3/conf/serverAddressAndPublicDiskSetup.sh       # Instructions as comment lines in the file

5) Add the main script CCseqBasic3.sh to your path or BASH profile (optional), f.ex :
    export PATH:${PATH}:/where/you/unpacked/it/CCseqBasic3/CCseqBasic3.sh

6) Start using the pipe ! (no installation needed)

7) Good place to start is the pipeline's help :
    CCseqBasic3.sh --help

8) Below web site provides a test data set, hands-on tutorials, full manual, and other documentation !
   http://userweb.molbiol.ox.ac.uk/public/telenius/CCseqBasicManual/
   
9) Direct link to the test data set :
   http://userweb.molbiol.ox.ac.uk/public/telenius/captureManual/testdata/exampledata.html
   