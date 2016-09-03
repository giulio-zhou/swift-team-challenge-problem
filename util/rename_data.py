import os
import sys
import skimage.io as skio

if len(sys.argv) < 2:
    print("Please include a path to the directory of images to be renamed")
    sys.exit(1)

img_files = filter(lambda x: x[-3:] != '.py', sorted(os.listdir(sys.argv[1])))
for i in range(len(img_files)):
    full_img_path = os.path.join(sys.argv[1], img_files[i])
    img = skio.imread(full_img_path)
    os.remove(full_img_path)
    skio.imsave(os.path.join(sys.argv[1], '%d.png' % i), img)
