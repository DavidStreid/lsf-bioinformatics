#!/bin/bash

if [[ -z "$1" ||  -z "$2" ]]
  then
    printf "Please provide a BAM directory and project name. \n ./contamination.sh {BAM_DIR} {PROJECT}\n"
  exit 1
fi

PROJECT_DIR=$1
PROJECT=$2
RESULTS=./contamination_output/${PROJECT}
# load in commands
. /home/streidd/pipeline-scripts/pipeline.config

num_bams=$(find  ${PROJECT_DIR} -type l -ls | grep bam | wc -l)
if [ "$num_bams" -eq "0" ]; then
   echo "No BAMs found in BAM dir provided";
   exit;
fi

echo "Running contamination on ${num_bams} BAMs. Results: ${RESULTS}"

mkdir -p "${RESULTS}"


# BAM=/ifs/res/IGO/fingerprint_reruns/06302_AH_5.21_rename/work/85/ba6b6251babd00409ca628fdcd499b/06302_AH__06302_AH_1472__C-YC8WEH__Tumor_headers.bam
# BAM=/ifs/res/IGO/fingerprint_reruns/06302_AH_5.21_rename/work/ff/35da7565fe5d7f1753841c89438b46/06302_AH__06302_AH_1472__C-YC8WEH__Tumor_headers.bam

for BAM in ${PROJECT_DIR}/*.bam;
do
   results_base=$(basename $BAM)
   pileup_result=${RESULTS}/pileup/${results_base}_pileups.table
   contamination_result=${RESULTS}/contamination/${results_base}_contamination.table

   echo "Processing $results_base"

   # exit

   $gatk GetPileupSummaries \
      -I ${BAM} \
      -V ${contamination_vcf} \
      -L ${contamination_interval_list} \
      -O ${pileup_result}
   $gatk CalculateContamination \
      -I ${pileup_result} \
      -O ${contamination_results}
done

echo "Finished."

