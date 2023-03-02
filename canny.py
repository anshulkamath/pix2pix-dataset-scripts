#!/usr/bin/env python

import argparse
import cv2
from matplotlib import pyplot as plt
from PIL import Image
import re

parser = argparse.ArgumentParser(prog='EdgeDetector', description='Takes in images and runs edge detection on them')

parser.add_argument('filename')
parser.add_argument('-o', '--output')
parser.add_argument('-s', '--show', action='store_true')
parser.add_argument('-d', '--dimension', default=256, type=int)
args = parser.parse_args()

img = cv2.cvtColor(cv2.imread(args.filename), cv2.COLOR_BGR2RGB)
edges = cv2.bitwise_not(cv2.Canny(img, 50, 200))

SIDE_DIMENSION = args.dimension

if args.show:
  plt.subplot(121),plt.imshow(img,cmap = 'gray')
  plt.title('Original Image'), plt.xticks([]), plt.yticks([])
  plt.subplot(122),plt.imshow(edges,cmap = 'gray')
  plt.title('Edge Image'), plt.xticks([]), plt.yticks([])
  plt.show()

if args.output:
  img = Image.fromarray(img)
  edges = Image.fromarray(edges)
  width, height = img.size

  prefix, extension = re.split(r'\.', args.output)

  if height != SIDE_DIMENSION:
    raise Exception(f'The images should have a height of 256 pixels, but instead has a height of {height}')
  
  if width == SIDE_DIMENSION:
    new_image = Image.new('RGB', (2 * height, height))
    new_image.paste(edges, (0, 0))
    new_image.paste(img, (SIDE_DIMENSION, 0))
    new_image.save(f'{prefix}a.{extension}')
    exit(0)

  new_images = [Image.new('RGB', (2 * height, height)) for _ in range(2)]

  left_crop = (
    *(im.crop((0, 0, SIDE_DIMENSION, height)) for im in (edges, img)),
    'a'
  )

  right_crop = (
    *(im.crop((width - SIDE_DIMENSION, 0, width, height)) for im in (edges, img)),
    'b'
  )

  for new_im in new_images:
    for (edges, im, suffix) in (left_crop, right_crop):
      new_im.paste(edges, (0, 0))
      new_im.paste(im, (SIDE_DIMENSION, 0))
      new_im.save(f'{prefix}{suffix}.{extension}')
