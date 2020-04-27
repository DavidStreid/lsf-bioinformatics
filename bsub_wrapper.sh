if [[ -z "$1"  ||  -z "$2" || -z "$3" ]]
  then
    printf "Please provide a project sample, paired fastq file paths, and project type.\nSee below,\n\t./bsub_wrapper.sh 07871_V \\ \n\t\t/ifs/input/GCL/hiseq/FASTQ/PITT_0466_BHGKL7BBXY/Project_07871_V/Sample_P-0000386-N01-WES_IGO_07871_V_3/P-0000386-N01-WES_IGO_07871_V_3_S44_R2_001.fastq.gz \\ \n\t\t/ifs/input/GCL/hiseq/FASTQ/PITT_0466_BHGKL7BBXY/Project_07871_V/Sample_P-0000386-N01-WES_IGO_07871_V_3/P-0000386-N01-WES_IGO_07871_V_3_S44_R1_001.fastq.gz \\ \n\t\twes\n"
  exit 1
fi

SAMPLE=$1
FASTQ1=$2
FASTQ2=$3
INPUT_TYPE=$4

WORK_DIR=/home/streidd/pipeline-scripts
SCRIPT=$WORK_DIR/bam_creation.sh

JOB_NAME="STAT_GEN:${SAMPLE}"

# load config
. $WORK_DIR/pipeline.config

# standardize project-type input
TYPE=$(echo "$INPUT_TYPE" | awk '{print tolower($0)}')
case $TYPE in
   wes)
       TYPE=wes
       GENOME=${REF_GENOME}
       ;;
  ped-peg)
       TYPE=ped-peg
       GENOME=${RNA_REF_GENOME}
       BAIT_INTERVAL=
       TARGET_INTERVAL=
       ;;
  *)
       TYPE=wgs
       GENOME=${REF_GENOME}
       BAIT_INTERVAL=
       TARGET_INTERVAL=
       ;;
esac

echo -e "\nSubmitting Project Type: ${TYPE}\n\nUsing following reference\n\tReference Genome: ${GENOME}\n\tBait Set: ${BAIT_INTERVAL}\n\tTarget Set: ${TARGET_INTERVAL}\n"
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
bsub -J $JOB_NAME -o $JOB_NAME.out -m $LSF_NODE -n 72 -M 6 "$SCRIPT $TYPE $FASTQ1 $FASTQ2 $SAMPLE $GENOME $BAIT_INTERVAL $TARGET_INTERVAL"
