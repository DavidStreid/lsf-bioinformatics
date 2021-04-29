# !/bin/bash
# Executes BWA_MEM w/ downsampling option
# Run: 
#   ./bam_util.sh  -1 Sample_r1.fastq.gz -2 Sample_r2.fastq.gz -r GRCh37.fastq.gz -d 10000

while getopts 1:2:r:d:o: flag
do
    case "${flag}" in
        1) FASTQ1=${OPTARG};;
        2) FASTQ2=${OPTARG};;
        r) REF_GENOME=${OPTARG};;
	d) DOWN_SAMPLE=${OPTARG};;
	o) OUTPUT_DIR=${OPTARG};;
    esac
done

if [[ -z "${FASTQ1}" ]]; then
  printf "Need to specify a fastq file '-1 sample.fastq.gz'\n"
  exit 1
fi
if [[ -z "${REF_GENOME}" ]]; then
  printf "Need a reference genome '-r ref.fastq.gz'\n"
  exit 1
fi
if [[ -z ${OUTPUT_DIR} ]]; then
  OUTPUT_DIR=.
fi

echo "FASTQ1: ${FASTQ1}";
echo "FASTQ2: ${FASTQ2}";
echo "REFERENCE: $REF_GENOME";
echo "OUTPUT: ${OUTPUT_DIR}"
#######################################
# 
# Arguments:
#   FASTQS - list of FASTQS
#######################################
function BWA_MEM(){
  REF="$1"
  SAMPLE="$2"
  FASTQS="${@:3}"
  CMD="/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa mem -M -t 36 $REF $FASTQS > ${OUTPUT_DIR}/${SAMPLE}.sam"
  echo $CMD
  $CMD
}

SAMPLE=$(printf "%s\n%s\n" "$(basename $FASTQ1)" "$(basename ${FASTQ2})" | sed -e 'N;s/^\(.*\).*\n\1.*$/\1/')
echo "Sample: $SAMPLE"
if [[ "${DOWN_SAMPLE}" != "" ]]; then
  echo "DOWN SAMPLE: ${DOWN_SAMPLE}";
  FASTQ_LIST=""
  for FASTQ in $FASTQ1 $FASTQ2; do
    FASTQ_FILE=$(basename $FASTQ)
    DS_FASTQ=${OUTPUT_DIR}/${FASTQ_FILE/.fastq.gz/}_ds${DOWN_SAMPLE}.fastq.gz
    echo "Downsampling ${FASTQ} by factor of ${DOWN_SAMPLE}: ${DS_FASTQ}"
    seqtk sample -s100 $FASTQ $DOWN_SAMPLE > $DS_FASTQ
    FASTQ_LIST="${FASTQ_LIST} ${DS_FASTQ}"
  done
  BWA_MEM ${REF_GENOME} ${SAMPLE} ${FASTQ_LIST}
else
  BWA_MEM ${REF_GENOME} ${SAMPLE} $FASTQ1 $FASTQ2  
fi

echo "Finished aligning $SAMPLE"

