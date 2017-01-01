import argparse
import cv2
import numpy as np
import os
import skimage
import skimage.io as skio
import sys
from skimage.transform import resize

parser = argparse.ArgumentParser(
    description="Evaluate image sequence using OpenCV benchmarks")
parser.add_argument('-v', '--version', type=int,
                    help="Which benchmark to evaluate [1, 2, 3]")
parser.add_argument('-f', '--filepath',
                    help="Path to directory containing image sequence")
parser.add_argument('-o', '--output',
                    help="Path to output directory for predictions",
                    default="opencv_output")
parser.add_argument('-x', '--xlen', type=int,
                    help="X dimension of video sequence")
parser.add_argument('-y', '--ylen', type=int,
                    help="Y dimension of video sequence")
parser.add_argument('-s', '--start', type=int,
                    help="Starting index of video sequence")
parser.add_argument('-e', '--end', type=int,
                    help="Ending index of video sequence")
args = parser.parse_args()


def apply_background_subtractor(fgbg, img_filenames, imgpath_prefix):
    masks = []
    for img in img_filenames: 
        curr_img = skio.imread(os.path.join(imgpath_prefix, img))
        curr_img = resize(curr_img, (args.ylen, args.xlen, 3))
        curr_img = skimage.img_as_ubyte(curr_img)
        mask = fgbg.apply(curr_img, learningRate=0.01)
        if np.sum(mask) == args.ylen * args.xlen * 255:
            mask[:, :] = 0
        masks.append(mask)
    return masks

def save_images(file_string, images):
    i = 0
    for img in images:
        skio.imsave(file_string.format(i), img)
        i += 1

def main():
    fgbg = None
    if args.version == 1:
        fgbg = cv2.BackgroundSubtractorMOG()
    elif args.version == 2:
        fgbg = cv2.BackgroundSubtractorMOG2(history=20, varThreshold=10, bShadowDetection=False)
    elif args.version == 3:
        fgbg = cv2.BackgroundSubtractorGMG()
    else:
        print "Please enter a version number between 1 and 3"
        return

    # Create output directory if does not exist
    if not os.path.exists(args.output):
        os.mkdir(args.output)

    # Read images from specified directory
    filenames = os.listdir(args.filepath)
    filenames = [x for x in filenames if x[0] != '.']
    # Sort filenames and only keep the proper ones
    filenames = sorted(filenames, key=lambda f: int(f.split('.')[0]))
    filenames = filenames[args.start:args.end]
    masks = apply_background_subtractor(fgbg, filenames, args.filepath)
    save_images(args.output + '/{}.png', masks)

if __name__ == '__main__':
    main()
