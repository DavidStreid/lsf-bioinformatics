if [[ -z "$1"  ||  -z "$2" || -z "$3" ]]
  then
    printf "Please provide a project sample, BAM, and project type.\nSee below,\n\t./bsub_picardGen_wrapper.sh 07871_V \\ \n\t\tWES_IGO_07871_V.bam\\ \n\t\twes\n"
  exit 1
fi

SAMPLE=$1
BAM=$2
INPUT_TYPE=$3

WORK_DIR=/home/streidd/pipeline-scripts
SCRIPT=$WORK_DIR/picard_generator.sh

JOB_NAME="PICARD:${SAMPLE}"

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
       BAIT_INTERVAL=NONE
       TARGET_INTERVAL=${RIBOSOMAL_INTERVALS}
       ;;
  *)
       TYPE=wgs
       GENOME=${REF_GENOME}
       BAIT_INTERVAL=NONE
       TARGET_INTERVAL=NONE
       ;;
esac

echo -e "\nSubmitting Project Type: ${TYPE}\n\nUsing following reference\n\tReference Genome: ${GENOME}\n\tBait Set: ${BAIT_INTERVAL}\n\tTarget Set: ${TARGET_INTERVAL}\n\tRef Flat: ${REF_FLAT}"
echo "Is this correct? Press 1/2"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Submitting job ${JOB_NAME}"; break;;
        No ) echo "Please modify the pipeline.config file"; exit;;
    esac
done

echo "Please provide an LSF node to run on"
read LSF_NODE

bsub -J $JOB_NAME -o $JOB_NAME.out -m $LSF_NODE -n 72 -M 6 "$SCRIPT $TYPE $BAM $SAMPLE $GENOME $BAIT_INTERVAL $TARGET_INTERVAL $REF_FLAT"
