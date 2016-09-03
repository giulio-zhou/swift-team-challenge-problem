#!/bin/bash
current_dir=`pwd`
cd $1
wget http://www.vis.uni-stuttgart.de/~hoeferbn/bse/dataset/SABS-Basic.rar
wget http://www.vis.uni-stuttgart.de/~hoeferbn/bse/dataset/SABS-GT.rar
unrar x SABS-Basic.rar
unrar x SABS-GT.rar
cd $current_dir
