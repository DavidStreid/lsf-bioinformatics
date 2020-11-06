# !/bin/bash
# Runs blast on an input BAM

FASTQ=$1
SAMPLE=$2

if [[ ! -f $FASTQ ]]; then
  echo "Need to specify FASTQ. Example:    ./fastq_to_blast.sh /path/to/fastq"
  exit 1
fi

if [[ -z ${SAMPLE} ]]; then
  SAMPLE="SAMPLE"
fi

JOB_NAME=FASTQ_${SAMPLE}
OUTPUT_BAM="${SAMPLE}.bam"
SUBMIT=$(bsub -J ${JOB_NAME} -e ${JOB_NAME}_error.log -o ${JOB_NAME}.log "java -jar /home/igo/resources/picard2.23.2/picard.jar FastqToSam O=${OUTPUT_BAM} F1=${FASTQ} SM=${SAMPLE} SO=coordinate && samtools index ${OUTPUT_BAM}")
echo "SUBMIT=${SUBMIT}"
JOB_ID=$(echo $SUBMIT | egrep -o '[0-9]{5,}')
echo "Waiting for ${JOB_ID} to finish"

JOB_NAME="BLAST_${SAMPLE}"
bsub -w "done(${JOB_ID})" -J ${JOB_NAME} -e ${JOB_NAME}_error.log -o ${JOB_NAME}.log "/home/igo/bin/taxblast/MAIN_UNMAPPED_count.bsh ${OUTPUT_BAM}  nt 40 200 100"
