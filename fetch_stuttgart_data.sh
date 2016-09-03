#!/bin/bash
current_dir=`pwd`
cd $1
wget http://www.vis.uni-stuttgart.de/~hoeferbn/bse/dataset/SABS-Basic.rar
wget http://www.vis.uni-stuttgart.de/~hoeferbn/bse/dataset/SABS-GT.rar
unrar x SABS-Basic.rar
unrar x SABS-GT.rar
cd $current_dir
python util/rename_data.py $1/SABS/Test/Basic 0 600
python util/rename_data.py $1/SABS/GT 800 1400
python util/convert_Stuttgart_GT_to_binary.py $1/SABS/GT
