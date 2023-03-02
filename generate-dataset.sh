#!/usr/bin/env bash

INPUT_DIR='input'
VIDEO_DIR='videos'
OUTPUT_DIR='output'
DATASET_NAME='pix2pix-dataset'
DIRECTORIES=()
EXTRACT_IMAGES=false

# image extraction rate in frames per second
HIGH_SAMPLE='1'
LOW_SAMPLE='1/3'

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

function extract_photos() {
  # Extract the images and downsize them
  for i in "${DIRECTORIES[@]}"; do
    IMG_HEIGHT='128'
    FFMPEG_OUTPUT_PREFIX="$INPUT_DIR/$i/$i-"

    if [[ $i == 'ny-skyline' ]]; then
      ffmpeg -i "$VIDEO_DIR/$i.mp4" -vf "fps=$LOW_SAMPLE,scale=-1:$IMG_HEIGHT" -q:v 2 "${FFMPEG_OUTPUT_PREFIX}%03d.jpg"
      continue
    fi

    ffmpeg -i "$VIDEO_DIR/$i.mp4" -vf "fps=$HIGH_SAMPLE,scale=-1:$IMG_HEIGHT" -q:v 2 "${FFMPEG_OUTPUT_PREFIX}%03d.jpg"
  done
}

function create_edges() {
  # Convert each image to canny counterpart
  for i in "${DIRECTORIES[@]}"; do
    FILE_DIR="$INPUT_DIR/$i"

    for j in $(ls "$INPUT_DIR/$i"); do
      FILE="$INPUT_DIR/$i/$j"
      ./canny.py "$FILE" -o "$FILE"
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
