if [[ -z "$1"  ||  -z "$2" || -z "$3" ]]
   then
      echo "ERROR: Need to specify fastqs and samples"
      exit 1
fi

F1=$1
F2=$2
SAMPLE=$3
MD_BAM=${SAMPLE}.bam
PE_BAM=${SAMPLE}___pe.bam
RG_BAM=${SAMPLE}___rg.bam
METRICS_FILE=${SAMPLE}___md.txt
HS_METRICS_FILE=${SAMPLE}___hs.txt
ALIGNMENT_SUMMARY_FILE=${SAMPLE}___AM.txt
CMD_LOG=${SAMPLE}_commands.log
# Load configuration file with references
. /home/streidd/pipeline-scripts/pipeline.config

PICARD_CMD=/home/upops/Scripts/PicardScripts/picard
BWA_CMD=/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa

RUN_AND_LOG() {
   echo $NEXT_CMD >> $CMD_LOG
   eval $NEXT_CMD
}

echo -e "Creating alignment bam \n\tO: ${PE_BAM} \n\tI: ${F1}, ${F2}"
NEXT_CMD="$BWA_CMD mem -M -t 8 $REF_GENOME $F1 $F2  | samtools view -bS - > $PE_BAM"
RUN_AND_LOG

echo -e "Creating read-group bam \n\tO: ${RG_BAM} \n\tI: ${PE_BAM}" 
NEXT_CMD="$PICARD_CMD AddOrReplaceReadGroups SO=coordinate CREATE_INDEX=true INPUT=$PE_BAM OUTPUT=$RG_BAM RGID=$SAMPLE RGLB=$SAMPLE RGPL=illumina RGPU=$SAMPLE RGSM=$SAMPLE RGCN=GCL@MSKCC"
RUN_AND_LOG

echo -e "Creating mark-dup bam \n\tO: ${MD_BAM} \n\tI: ${RG_BAM}"
NEXT_CMD="$PICARD_CMD MarkDuplicates CREATE_INDEX=true METRICS_FILE=$METRICS_FILE OUTPUT=$MD_BAM INPUT=$RG_BAM"
RUN_AND_LOG

echo -e "Running hs metrics" 
NEXT_CMD="$PICARD_CMD CollectHsMetrics \
	BI=$BAIT_INTERVAL \
	TI=$TARGET_INTERVAL \
	I=$MD_BAM O=$HS_METRICS_FILE"
RUN_AND_LOG

echo -e "Running CollectAlignmentSummaryMetrics"
NEXT_CMD="$PICARD_CMD CollectAlignmentSummaryMetrics \
    MAX_INSERT_SIZE=1000 \
    I=$MD_BAM \
    O=$ALIGNMENT_SUMMARY_FILE \
    R=$REF_GENOME"
RUN_AND_LOG

echo "DONE" 
