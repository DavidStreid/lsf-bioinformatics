if [[ -z "$1"  ||  -z "$2" || -z "$3"  ]]
   then
      echo "ERROR: Need to specify fastqs and samples - ./bam_creation.sh {FASTQ1} {FASTQ2} {GENOME} {SAMPLE} {wes/ped-peg}"
      printf "\te.g.\t./bam_creation.sh sample_R1_001.fastq.gz sample_R2_001.fastq.gz ./GRCh37.fastq.gz SAMPLE_ID wes\n"
      exit 1
fi

F1=$1
F2=$2
GENOME=$3
SAMPLE=$4		# optional param
TYPE=$5			# optional param
BAIT_INTERVAL=$6	# optional param
TARGET_INTERVAL=$7	# optional param
REF_FLAT=$8		# optional param

# bam files
MD_BAM=${SAMPLE}.bam
PE_BAM=${SAMPLE}___pe.bam
RG_BAM=${SAMPLE}___rg.bam

# metrics files
METRICS_FILE=${SAMPLE}___md.txt
HS_METRICS_FILE=${SAMPLE}___hs.txt
ALIGNMENT_SUMMARY_FILE=${SAMPLE}___AM.txt
RNA_METRICS_FILE=${SAMPLE}___RNA.txt

CMD_LOG=${SAMPLE}_commands.log

PICARD_CMD=/home/igo/Scripts/PicardScripts/picard
# /home/upops/Scripts/PicardScripts/picard
BWA_CMD=/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa

# runs and logs the globally-set NEXT_CMD variable
RUN_AND_LOG() {
   date >> $CMD_LOG
   echo $NEXT_CMD >> $CMD_LOG
   eval $NEXT_CMD
   date >> $CMD_LOG
   echo "" >> $CMD_LOG
}

echo -e "Creating alignment bam \n\tO: ${PE_BAM} \n\tI: ${F1}, ${F2}"
NEXT_CMD="$BWA_CMD mem -M -t 8 $GENOME $F1 $F2  | samtools view -bS - > $PE_BAM"
RUN_AND_LOG

echo -e "Creating read-group bam \n\tO: ${RG_BAM} \n\tI: ${PE_BAM}" 
NEXT_CMD="$PICARD_CMD AddOrReplaceReadGroups SO=coordinate CREATE_INDEX=true INPUT=$PE_BAM OUTPUT=$RG_BAM RGID=$SAMPLE RGLB=$SAMPLE RGPL=illumina RGPU=$SAMPLE RGSM=$SAMPLE RGCN=GCL@MSKCC"
RUN_AND_LOG

echo -e "Creating mark-dup bam \n\tO: ${MD_BAM} \n\tI: ${RG_BAM}"
NEXT_CMD="$PICARD_CMD MarkDuplicates CREATE_INDEX=true METRICS_FILE=$METRICS_FILE OUTPUT=$MD_BAM INPUT=$RG_BAM"
RUN_AND_LOG

echo -e "Running CollectAlignmentSummaryMetrics"
NEXT_CMD="$PICARD_CMD CollectAlignmentSummaryMetrics \
    MAX_INSERT_SIZE=1000 \
    I=$MD_BAM \
    O=$ALIGNMENT_SUMMARY_FILE \
    R=$GENOME"
RUN_AND_LOG

case $TYPE in
   wes)
      echo -e "Running hs metrics for Whole Exome Project" 
      NEXT_CMD="$PICARD_CMD CollectHsMetrics \
         BI=$BAIT_INTERVAL \
         TI=$TARGET_INTERVAL \
         I=$MD_BAM O=$HS_METRICS_FILE"
      RUN_AND_LOG
    ;;

   ped-peg)
      echo -e "Running Rna-Seq Metrics for Whole Genome Project"
      NEXT_CMD="$PICARD_CMD CollectRnaSeqMetrics \
         RIBOSOMAL_INTERVALS=$TARGET_INTERVAL \
         STRAND_SPECIFICITY=NONE \
         REF_FLAT=$REF_FLAT \
         I=$MD_BAM \
         O=$RNA_METRICS_FILE"
      RUN_AND_LOG
   ;;
esac

echo "DONE" 
