# !/bin/bash
# Executes BWA_MEM w/ downsampling option
# Run:
#   ./bam_stats.sh -s gc_bias -b bam (-r REF_GENOME)

while getopts b:r: flag
do
    case "${flag}" in
        b) BAM=${OPTARG};;
        r) REF_GENOME=${OPTARG};;
    esac
done

# Check for mandatory arguments
if [[ -z $BAM || -z $REF_GENOME ]]; then
  echo "Usage: ./bam_stats.sh -b bam -r REF_GENOME"
  exit 1
fi

if [ ! -f "$BAM" ]; then
  echo "$BAM does not exist."
  exit 1
fi

BAM_FILE_NAME=$(basename $BAM)

# DERIVED ARGUMENTS
SAMPLE=${BAM_FILE_NAME/.bam/}

GC_BIAS_CMD="picard CollectGcBiasMetrics I=$BAM O=${SAMPLE}_gc_bias_metrics.txt CHART=${SAMPLE}_gc_bias_metrics.pdf S=${SAMPLE}_summary_metrics.txt R=${REF_GENOME}"
JOB_NAME="GC_BIAS___${SAMPLE}"
BSUB_CMD="bsub -J ${JOB_NAME} -o ${SAMPLE}.out -e ${SAMPLE}.err -n 36 -M 6 ${GC_BIAS_CMD}"
echo "RUNNING JOB: ${JOB_NAME}"
echo $BSUB_CMD
$BSUB_CMD
