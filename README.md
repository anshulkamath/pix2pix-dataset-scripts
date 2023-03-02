# How to use

This repo is meant to create a pix2pix dataset from given videos (.mp4 files).
To use this, first run `pip install -r requirements.txt` (preferably in a virtual environment).
Then, create a `videos/` directory and put your mp4s in there.
Finally, you can run `./generate-dataset.sh` to run the script.

If you need to extract images from your video (which is probably the case), then set the
`EXTRACT_IMAGES` variable to `true` in the script. You can change the extraction rate given in the
`LOW_SAMPLE` variable. The `HIGH_SAMPLE` variable is an exception that I added.
