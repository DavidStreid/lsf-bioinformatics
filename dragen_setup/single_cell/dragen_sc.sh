#!/bin/bash
# ./dragen_sc.sh /igo/delivery/FASTQ/MICHELLE_0144_BHLCYHDMXX/Project_10051/Sample_Lib34_ES_2i_plusLIF_3_IGO_10051_18

FASTQ_DIR=$1	   # lib1_S7_L001_R2_001.fastq.gz
ANNOTATION_FILE=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-mm10-2020-A/genes/genes.gtf  # $2 # reference_genomes/Mus_musculus/mm10/gtf/gencode.vM23.annotation.gtf.gz
REFERENCE_FILE=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-mm10-2020-A/fasta/genome.fa # $3  # reference_genomes/Mus_musculus/mm10/DRAGEN/8 
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
