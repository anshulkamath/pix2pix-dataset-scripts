# How to use

This repo is meant to create a pix2pix dataset from given videos (.mp4 files).
To use this, first run `pip install -r requirements.txt` (preferably in a virtual environment).
Additionally, if you don't have `ffmpeg`, you should download that (`brew install ffmpeg` if you have homebrew).
Then, create a `videos/` directory and put your mp4s in there.
Finally, you can run `./generate-dataset.sh` to run the script (if you get a permission denied error,
run `chmod +x generate-dataset.sh`).

If you need to extract images from your video (which is probably the case), then set the
`EXTRACT_IMAGES` variable to `true` using the `-w` flag.

Here is a full set of flags:

```Usage: ./generate-dataset [options]```

|Flag | Alias | Help | Default|
|-----|-------|------|--------|
|--training-output | (-t) | The output directory for training images. | `output`|
|--frames          | (-f) | The number of evenly-spaced frames to pull from each video. | 200|
|--size            | (-s) | The desired height of each image. | 256|
|--input           | (-i) | The input directory that contains videos. | `videos`|
|--output          | (-o) | The desired name of the .zip file with all the data. | `pix2pix-dataset`|
|--write           | (-w) | Will overwrite and regenerate all images. | `false`|
