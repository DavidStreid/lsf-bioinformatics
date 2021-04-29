#!/bin/bash
# ./dragen_sc.sh /PATH/TO/SAMPLE/DEMUX

FASTQ_DIR=$1
ANNOTATION_FILE=$2 # Grab these from the 10x reference downloads - https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/advanced/references
REFERENCE_FILE=$3
OUTPUT=$(pwd)
SAMPLE=$(basename ${FASTQ_DIR} | grep -oP "(?<=Sample_).*")

FASTQ_FILES=$(find ${FASTQ_DIR} -type f -name "${SAMPLE}*R[12]_001*.fastq.gz")

for f in ${FASTQ_FILES}; do
  LANE=$(basename $f | grep -oP "(?<=L00)[\d]")
  /opt/edico/bin/dragen \
    --enable-rna=true \
    --enable-single-cell-rna=true \
    -r ${REFERENCE_FILE} \
    -a ${ANNOTATION_FILE} \
    -1 ${FASTQ_DIR} \
    --RGID=${LANE} \
    --RGSM=${SAMPLE} \
    --output-dir=${OUTPUT} \
    --output-file-prefix=${SAMPLE}
    # --single-cell-barcode 0_15 \
    # --single-cell-umi 16_25 \
    # --umi-fastq lib1_S7_L001_R1_001.fastq.gz \
  exit 0
done

# ...I1_001.fastq.gz
# @NB501987:97:HHLYKAFXY:1:11101:22804:1043 1:N:0:GGTTTACT
# GATCGNTTCAGTCCCTAATGACTTTGT
# +
# AAAAA#EEEEEEEEEEEEEEEEEEEE/

# ...L001_R1_001.fastq.gz
# @NB501987:97:HHLYKAFXY:1:11101:22804:1043 1:N:0:GGTTTACT
# GGTTTACT
# +
# AA/AAAEA
