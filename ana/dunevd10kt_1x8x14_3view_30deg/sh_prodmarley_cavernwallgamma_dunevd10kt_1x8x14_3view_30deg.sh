#!/bin/bash
number=v09_81_00
export myworkpath=/afs/cern.ch/work/s/smanthey
export pathLarSoft=$myworkpath/larsoft_${number}
export FW_SEARCH_PATH=${pathLarSoft}/:$FW_SEARCH_PATH
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
source ${pathLarSoft}/localProducts_larsoft*/setup
mrbslp
mrb uc
mrbsetenv
mrbslp
mrbslp

#--------------------------------------#

export det=dunevd10kt_1x8x14_3view_30deg
export gen=prodmarley_cavernwallgamma

#--------------------------------------#

export evgenfcl=$pathLarSoft/srcs/dunesw/fcl/dunefdvd/gen/solar/${gen}_${det}.fcl
export G4stage1fcl=$pathLarSoft/srcs/dunesw/fcl/dunefdvd/g4/standard_g4stage1_${det}.fcl
export G4stage2fcl=$pathLarSoft/srcs/dunesw/fcl/dunefdvd/g4/standard_g4stage2_${det}.fcl
export detsimfcl=$pathLarSoft/srcs/dunesw/fcl/dunefdvd/detsim/standard_detsim_${det}.fcl
export recofcl=$pathLarSoft/srcs/dunesw/fcl/dunefdvd/reco/solar_reco_${det}.fcl
# export reco2fcl=$pathLarSoft/srcs/dunesw/fcl/dunefdvd/reco/standard_reco2_${det}.fcl
export anafcl=$pathLarSoft/srcs/duneana/duneana/SolarNuAna/fcl/solar_ana_${det}.fcl

#--------------------------------------#

declare -i evt_total=1
declare -i evt_per_file=1
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
    export G4stage1ROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4stage1.root"
    export G4stage2ROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4stage1_g4stage2.root"
    export DetSimROOTFile=$gen"_"${det}"_"${timestamp}"_gen_g4stage1_g4stage2_detsim.root"
    export RecoROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4stage1_g4stage2_detsim_reco.root"
    # export Reco2ROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4stage1_g4stage2_detsim_reco1_reco2.root"
    export AnaROOTFile=${gen}"_"${det}"_"${timestamp}"_gen_g4stage1_g4stage2_detsim_reco_ana.root"

    lar -c $evgenfcl -n $nevt -o $genROOTFile

    lar -c $G4stage1fcl $genROOTFile -n $nevt -o $G4stage1ROOTFile
    rm $genROOTFile

    lar -c $G4stage2fcl $G4stage1ROOTFile -n $nevt -o $G4stage2ROOTFile
    rm $G4stage1ROOTFile

    lar -c $detsimfcl $G4stage2ROOTFile -n $nevt -o $DetSimROOTFile
    rm $G4stage2ROOTFile

    lar -c $recofcl $DetSimROOTFile -n $nevt -o $RecoROOTFile
    rm $DetSimROOTFile

    lar -c $anafcl $RecoROOTFile -n $nevt -T $AnaROOTFile
    rm $RecoROOTFile
done