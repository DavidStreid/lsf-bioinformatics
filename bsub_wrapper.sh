if [[ -z "$1"  ||  -z "$2" || -z "$3" ]]
  then
    printf "Please provide a project sample & fastq files. See below,\n\t./bsub_wrapper.sh 07871_V /ifs/input/GCL/hiseq/FASTQ/PITT_0466_BHGKL7BBXY/Project_07871_V/Sample_P-0000386-N01-WES_IGO_07871_V_3/P-0000386-N01-WES_IGO_07871_V_3_S44_R2_001.fastq.gz /ifs/input/GCL/hiseq/FASTQ/PITT_0466_BHGKL7BBXY/Project_07871_V/Sample_P-0000386-N01-WES_IGO_07871_V_3/P-0000386-N01-WES_IGO_07871_V_3_S44_R1_001.fastq.gz\n"
  exit 1
fi

SAMPLE=$1
FASTQ1=$2
FASTQ2=$3

WORK_DIR=/home/streidd/pipeline-scripts
SCRIPT=$WORK_DIR/bam_creation.sh

JOB_NAME="STAT_GEN:${SAMPLE}"

# load config
. $WORK_DIR/pipeline.config

echo -e "Using following reference\n\tReference Genome: ${REF_GENOME}\n\tBait Set: ${BAIT_INTERVAL}\n\tTarget Set: ${TARGET_INTERVAL}"
echo "Is this correct? Press 1/2"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Submitting job ${JOB_NAME}"; break;;
        No ) echo "Please modify the pipeline.config file"; exit;;
    esac
done

echo "Please provide an LSF node to run on"
read LSF_NODE

# We are running all of the jobs on a 72-CPU node
bsub -J $JOB_NAME -o $JOB_NAME.out -m $LSF_NODE -n 72 -M 6 "$SCRIPT $FASTQ1 $FASTQ2 $SAMPLE"
