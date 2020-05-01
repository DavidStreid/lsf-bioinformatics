if [[ -z "$1"  ||  -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]
   then
      echo "ERROR: Need to specify fastqs and samples"
      exit 1
fi

TYPE=$1
MD_BAM=$2
SAMPLE=$3
GENOME=$4
BAIT_INTERVAL=$5	# optional param
TARGET_INTERVAL=$6	# optional param
REF_FLAT=$7		# optional param

# metrics files
HS_METRICS_FILE=${SAMPLE}___hs.txt
ALIGNMENT_SUMMARY_FILE=${SAMPLE}___AM.txt
RNA_METRICS_FILE=${SAMPLE}___RNA.txt

CMD_LOG=${SAMPLE}_commands.log

PICARD_CMD=/home/upops/Scripts/PicardScripts/picard

# runs and logs the globally-set NEXT_CMD variable
RUN_AND_LOG() {
   date >> $CMD_LOG
   echo $NEXT_CMD >> $CMD_LOG
   eval $NEXT_CMD
   date >> $CMD_LOG
   echo "" >> $CMD_LOG
}

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
