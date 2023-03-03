#!/usr/bin/env bash

INPUT_DIR='input'
VIDEO_DIR='videos'
OUTPUT_DIR='output'
DATASET_NAME='pix2pix-dataset'
DIRECTORIES=()
EXTRACT_IMAGES=false
PYTHON_DIR=$(which python3)

# image extraction rate in frames per second
SAMPLE_FRAMES=200
IMG_HEIGHT=256

while [[ $# -gt 0 ]]; do
  case $1 in
  -t|--training-output)
      shift
      OUTPUT=$1
      shift
      ;;
  -f|--frames)
      shift
      SAMPLE_FRAMES=$1
      shift
      ;;
  -s|--size)
      shift
      IMG_HEIGHT=$1
      shift
      ;;
  -i|--input)
      shift
      VIDEO_DIR=$1
      shift
      ;;
  -o|--output)
      shift
      DATASET_NAME=$1
      shift
      ;;
  -w|--overwrite)
    EXTRACT_IMAGES=true
    shift
    ;;
  -h|--help|-*|--*)
      echo 'Usage: ./generate-dataset [options]'
      echo "    --training-output (-t) - The output directory for training images. Default: `output`"
      echo "    --frames          (-f) - The number of evenly-spaced frames to pull from each video. Default: 200"
      echo "    --size            (-s) - The desired height of each image. Default: 256"
      echo "    --input           (-i) - The input directory that contains videos. Default: `videos`"
      echo "    --output          (-o) - The desired name of the .zip file with all the data. Default: `pix2pix-dataset`"
      echo "    --write           (-w) - Will overwrite and regenerate all images. Default: `false`"
      shift
      exit 0
      ;;
  esac
done

function make_directories() {
  # Create necessary input directories
  if [[ ! -d $INPUT_DIR ]]; then
    mkdir $INPUT_DIR
  fi

  for i in $(ls $VIDEO_DIR); do
    curr="${i%.mp4}"

    DIRECTORIES+=("$curr")
    DIRECTORY_PATH="$INPUT_DIR/$curr"

    if ! $EXTRACT_IMAGES; then
      continue
    fi

    if [[ -d $DIRECTORY_PATH ]]; then
      rm -rf $DIRECTORY_PATH
    fi

    mkdir $DIRECTORY_PATH
  done
}

# gets the necessary frame rate from the video and the desired number of frames
function get_frame_rate() {
  local duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1)
  $PYTHON_DIR -c "print(int($2)/int($duration))"
}

function extract_photos() {
  # Extract the images and downsize them
  for i in "${DIRECTORIES[@]}"; do
    FFMPEG_OUTPUT_PREFIX="$INPUT_DIR/$i/$i-"
    local frame_rate=$(get_frame_rate "$VIDEO_DIR/$i.mp4" $SAMPLE_FRAMES)
    ffmpeg -i "$VIDEO_DIR/$i.mp4" -vf "fps=$frame_rate,scale=-1:$IMG_HEIGHT" -q:v 2 "${FFMPEG_OUTPUT_PREFIX}%03d.jpg"
  done
}

function create_edges() {
  # Convert each image to canny counterpart
  for i in "${DIRECTORIES[@]}"; do
    FILE_DIR="$INPUT_DIR/$i"

    for j in $(ls "$INPUT_DIR/$i"); do
      FILE="$INPUT_DIR/$i/$j"
      $PYTHON_DIR canny.py $FILE -o $FILE -d $IMG_HEIGHT
      rm $FILE
    done
  done
}

function create_dataset() {
  splitfolders --output "$OUTPUT_DIR" --ratio .8 .1 .1 -- $INPUT_DIR
  for i in $(ls $OUTPUT_DIR); do
    for j in "${DIRECTORIES[@]}"; do
      mv $OUTPUT_DIR/$i/$j/* $OUTPUT_DIR/$i
      rmdir $OUTPUT_DIR/$i/$j
    done
  done

  zip -r $DATASET_NAME $OUTPUT_DIR >> /dev/null
}

make_directories
if $EXTRACT_IMAGES ; then
  extract_photos
  create_edges
fi
create_dataset
