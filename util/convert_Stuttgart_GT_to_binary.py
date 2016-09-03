import numpy as np
import os
import skimage.io as skio
import sys

if len(sys.argv) < 2:
    print("Please provide an input directory to convert")
    sys.exit(1)

img_files = filter(lambda x: x[-3:] != '.py', os.listdir(sys.argv[1]))
for img_file in img_files:
    img = skio.imread(os.path.join(sys.argv[1], img_file))
    img = img[:, :, :3]
    temp_img = np.sum(img, axis=2)
    y, x = np.where(temp_img != 0)
    img[y, x, 0*np.ones(len(y)).astype(np.int)] = 255
    img[y, x, 1*np.ones(len(y)).astype(np.int)] = 255
    img[y, x, 2*np.ones(len(y)).astype(np.int)] = 255
    img = img[:, :, 0]
    skio.imsave(os.path.join(sys.argv[1], img_file), img)
