#!/bin/bash
export det=dune10kt_1x2x6_legacy

export timestamp=${1}_${2}
export filenum=${3}
export filelist=${4}

export RecoROOTFile=$(sed "${filenum}q;d" $filelist)
export AnaROOTFile=${det}"_"${timestamp}"_ana.root"

number=v09_78_03
export myworkpath=/afs/cern.ch/work/s/smanthey
export pathLarSoft=$myworkpath/larsoft_${number}
export anafcl=${pathLarSoft}/srcs/duneana/duneana/SolarNuAna/fcl/solar_ana_dune10kt_1x2x6_mcc11.fcl
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
source ${pathLarSoft}/localProducts_larsoft*/setup
mrbslp
mrb uc
mrbsetenv

#--------------------------------------#

echo ":AjpP_;oQb2tE" | kinit -f smanthey@FNAL.GOV
kx509
export ROLE=Analysis
voms-proxy-init -rfc -noregen -voms=dune:/dune/Role=$ROLE -valid 120:00

#--------------------------------------#

export LC_ALL=en_US.UTF-8  
export LC_CTYPE=en_US.UTF-8

#--------------------------------------# 
# Make a printout of the variables
echo "timestamp: " $timestamp
echo "filenum: " $filenum
echo "filelist: " $filelist

#--------------------------------------#
# Make a printout of the RecoROOTFile and AnaROOTFile
echo "RecoROOTFile: " $RecoROOTFile
echo "AnaROOTFile: " $AnaROOTFile

lar -c $anafcl $RecoROOTFile -T $AnaROOTFile