import os
import sys
import skimage.io as skio

if len(sys.argv) < 4:
    print("Usage: python rename_data.py [path_to_img_dir] [start_frame] [end_frame]")
    sys.exit(1)

start_frame = int(sys.argv[2])
end_frame = int(sys.argv[3])
img_files = filter(lambda x: x[-3:] != '.py', sorted(os.listdir(sys.argv[1])))
for i in range(len(img_files)):
    full_img_path = os.path.join(sys.argv[1], img_files[i])
    if i in range(start_frame, end_frame):
        img = skio.imread(full_img_path)
        skio.imsave(os.path.join(sys.argv[1], '%d.png' % (i - start_frame)), img)
    os.remove(full_img_path)
