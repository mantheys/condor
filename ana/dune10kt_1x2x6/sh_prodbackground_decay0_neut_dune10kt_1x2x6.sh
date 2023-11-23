#!/bin/bash
number=v09_76_00
export myworkpath=/afs/cern.ch/work/s/smanthey
export pathLarSoft=$myworkpath/larsoft_${number}
export FW_SEARCH_PATH=${pathLarSoft}/:$FW_SEARCH_PATH
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
source ${pathLarSoft}/localProducts_larsoft*/setup
mrbslp
mrb uc
mrbsetenv

#--------------------------------------#

export det=dune10kt_1x2x6
export gen=prodbackground_decay0_neut

#--------------------------------------#

export evgenfcl=$pathLarSoft/srcs/dunesw/fcl/dunefd/gen/solar/${gen}_${det}.fcl
export G4fcl=$pathLarSoft/srcs/dunesw/fcl/dunefd/g4/supernova_g4_${det}.fcl
export detsimfcl=$pathLarSoft/srcs/dunesw/fcl/dunefd/detsim/standard_detsim_${det}.fcl
export reco1fcl=$pathLarSoft/srcs/dunesw/fcl/dunefd/reco/solar_reco1_${det}.fcl
export reco2fcl=$pathLarSoft/srcs/dunesw/fcl/dunefd/reco/standard_reco2_${det}.fcl
export anafcl=$pathLarSoft/srcs/duneana/duneana/SolarNuAna/fcl/solar_ana_${det}.fcl

#--------------------------------------#

declare -i evt_total=20
declare -i evt_per_file=20
declare -i nfiles=evt_total/evt_per_file
declare -i filenum
declare -i ifilenum=0

export nevt=$evt_per_file

#--------------------------------------#

export LC_ALL=en_US.UTF-8  
export LC_CTYPE=en_US.UTF-8

#--------------------------------------# 

for ((filenum=ifilenum; filenum < nfiles+ifilenum  ; filenum=filenum+1 ));
    do
    # If arguments are provided when calling the script, use them as the timestamp
    # Otherwise, use the current time
    if [ $# -eq 0 ]; then
        export timestamp=$(date +%Y-%m-%d_%H-%M-%S-%6N)
    else
        export timestamp=${1}_${2}
    fi

    export genROOTFile=${gen}"_"${det}"_"${timestamp}"_gen.root"
    export G4ROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4.root"
    export DetSimROOTFile=$gen"_"${det}"_"${timestamp}"_gen_g4_detsim.root"
    export Reco1ROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4_detsim_reco1.root"
    export Reco2ROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4_detsim_reco2.root"
    export AnaROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4_detsim_reco2_ana.root"

    lar -c $evgenfcl -n $nevt -o $genROOTFile

    lar -c $G4fcl $genROOTFile -n $nevt -o $G4ROOTFile
    rm $genROOTFile

    lar -c $detsimfcl $G4ROOTFile -n $nevt -o $DetSimROOTFile
    rm $G4ROOTFile

    lar -c $reco1fcl $DetSimROOTFile -n $nevt -o $Reco1ROOTFile
    rm $DetSimROOTFile

    lar -c $reco2fcl $Reco1ROOTFile -n $nevt -o $Reco2ROOTFile
    rm $Reco1ROOTFile

    lar -c $anafcl $Reco2ROOTFile -n $nevt -T $AnaROOTFile
    rm $Reco2ROOTFile
done