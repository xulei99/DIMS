#!/bin/bash
scripts=$1
outdir=$2
indir=$3
thresh=$4
resol=$5
scanmode=$6
normalization=$7
jobs=$8

echo "### Inputs queuePeakFinding.sh ###############################################"
echo "	scripts:	${scripts}"
echo "	outdir:		${outdir}"
echo "	indir:		${indir}"
echo "	thresh:   ${thresh}"
echo "	resol:    ${resol}"
echo "	scanmode: ${scanmode}"
echo "	normalization: ${normalization}"
echo "#############################################################################"

if [ "$scanmode" == "negative" ]; then
 label="*_neg.RData"
else
 label="*_pos.RData"
fi

find "$outdir/average_pklist" -iname $label | while read sample;
 do
     echo "Processing file $sample"
     qsub -l h_rt=00:30:00 -l h_vmem=8G -N "peakFinding_$scanmode" -o $jobs -e $jobs -m as $scripts/runPeakFinding.sh $sample $scripts $outdir $thresh $resol $scanmode
 done

qsub -l h_rt=00:15:00 -l h_vmem=8G -N "collect_$scanmode" -o $jobs -e $jobs -m as -hold_jid "peakFinding_$scanmode" $scripts/runCollectSamples.sh $scripts $outdir $scanmode
qsub -l h_rt=00:10:00 -l h_vmem=1G -N "queueGrouping_$scanmode" -o $jobs -e $jobs -m as -hold_jid "collect_$scanmode" $scripts/queuePeakGrouping.sh $scripts $outdir $indir $thresh $resol $scanmode $normalization
