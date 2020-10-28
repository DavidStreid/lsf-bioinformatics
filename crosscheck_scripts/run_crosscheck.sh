# !/bin/bash
# 
# Run: 
#   

while getopts f:n: flag
do
    case "${flag}" in
        f) BAM_INPUTS=${OPTARG};;
        n) BASE_NAME=${OPTARG};;
    esac
done

if [[ -z $BAM_INPUTS ]]; then
  echo "Need BAM input file"
  echo "./run_crosscheck.sh -f {FILE_OF_BAMS} -n {ANALYSIS_NAME}"
  exit 1
fi

if [[ -z $BASE_NAME ]]; then
  BASE_NAME="DEFAULT"
fi

readonly OUTPUT="./${BASE_NAME}.crosscheck_metrics"
HAPLOTYPE_MAP=/home/igo/resources/fingerprinting/hg19_nochr.map
JOB_NAME=CROSSCHECK_FRPNT:${BASE_NAME}

bsub -J ${JOB_NAME} -e ${JOB_NAME}_error.log -o ${JOB_NAME}.log -n 4 -M 12 "java -jar -Xmx48g \
  /home/streidd/dependencies/picard/picard.jar CrosscheckFingerprints \
  NUM_THREADS=4 \
  CROSSCHECK_BY=FILE \
  OUTPUT=$OUTPUT \
  LOD_THRESHOLD=-5 \
  HAPLOTYPE_MAP=${HAPLOTYPE_MAP} \
  INPUT=$BAM_INPUTS"
