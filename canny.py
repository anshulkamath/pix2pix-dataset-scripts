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
parser.add_argument('-e', '--edges', action='store_true', help='only outputs the canny image')

side_group = parser.add_mutually_exclusive_group()
side_group.add_argument('-r', '--right', action='store_true', help='only outputs the right image')
side_group.add_argument('-l', '--left', action='store_true', help='only outputs the left image')
args = parser.parse_args()

SIDE_DIMENSION = args.dimension

img = cv2.cvtColor(cv2.imread(args.filename), cv2.COLOR_BGR2RGB)

# resize the image if it is too big
height, width, _ = img.shape
if height != SIDE_DIMENSION:
    width = int(SIDE_DIMENSION / height * width)
    height = SIDE_DIMENSION

    img = cv2.resize(img, (width, height), interpolation = cv2.INTER_AREA)
    print(f'Height of given image is {height}, but should be {SIDE_DIMENSION}. Resizing. New dimensions are: ({width}, {height})')

edges = cv2.bitwise_not(cv2.Canny(img, 50, 200))

if args.show:
  if args.edges:
    plt.title('Edge Image'), plt.xticks([]), plt.yticks([])
    plt.imshow(edges, cmap='gray')
  else:
    plt.subplot(121),plt.imshow(img,cmap = 'gray')
    plt.title('Original Image'), plt.xticks([]), plt.yticks([])
    plt.subplot(122),plt.imshow(edges,cmap = 'gray')
    plt.title('Edge Image'), plt.xticks([]), plt.yticks([])
  
  plt.show()

if args.output:
  img = Image.fromarray(img)
  edges = Image.fromarray(edges)
  num_images = 2 - int(args.edges)
  new_width = height * num_images

  prefix, extension = re.split(r'\.', args.output)
  
  if width == SIDE_DIMENSION:
    new_image = Image.new('RGB', (new_width, height))
    new_image.paste(edges, (0, 0))
    if not args.edges:
      new_image.paste(img, (SIDE_DIMENSION, 0))
    new_image.save(f'{prefix}a.{extension}')
    exit(0)

  new_images = [Image.new('RGB', (new_width, height)) for _ in range(num_images)]

  left_crop = (
    *(im.crop((0, 0, SIDE_DIMENSION, height)) for im in (edges, img)),
    'a'
  )

  right_crop = (
    *(im.crop((width - SIDE_DIMENSION, 0, width, height)) for im in (edges, img)),
    'b'
  )

  if args.edges and args.left:
    right_crop = None
  if args.edges and args.right:
    left_crop = None

  for new_im in new_images:
    for crop in (left_crop, right_crop):
        if not crop:
          continue

        (edges, im, suffix) = crop
        if args.left or args.right:
          suffix = ''
        
        new_im.paste(edges, (0, 0))
        
        if not args.edges:
          new_im.paste(im, (SIDE_DIMENSION, 0))

        new_im.save(f'{prefix}{suffix}.{extension}')
