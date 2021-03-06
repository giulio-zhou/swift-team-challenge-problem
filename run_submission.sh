#!/bin/bash
# Usage: ./run_experiment.sh [data directory] [xlen] [ylen] [training start timestep] [training end timestep] \
#                            [test start timestep] [test end timestep] [output directory] [ground truth image directory]
#
# Phase One: Perform offline inference on first n frames to get parameters
# Variable declarations
data_dir=$1
xlen=$2
ylen=$3
training_start_t=$4
training_end_t=$5
test_start_t=$6
test_end_t=$7
output_dir=$8
ground_truth_dir=$9
# Declare integers for arithmetic
declare -i xlen
declare -i ylen
declare -i training_start_t
declare -i training_end_t
declare -i test_start_t
declare -i test_end_t

num_param_samples=$((xlen * ylen * 6 * 25))
train_time_steps=$(( training_end_t - training_start_t ))
test_time_steps=$(( test_end_t - test_start_t ))
declare -i train_time_steps
declare -i test_time_steps
num_label_interval=$((xlen * ylen * test_time_steps / 4))
num_label_burn_in=$((xlen * ylen * test_time_steps * 5))
num_label_samples=$((xlen * ylen * test_time_steps * 20))

# Make BLOG file, load images and means from pre-processing to Swift-readable text format
python util/make_blog_file.py --input_name templates/bsub_offline_learn_param.blog --output_name swift/example/bsub_offline.blog --query_type offline_param -t $training_end_t --xlen $xlen --ylen $ylen
python util/make_param_txt.py --input_dir . --data_dir $data_dir --sequence_time_start $training_start_t --sequence_time_end $training_end_t --query_type read_img_sequence --xlen $xlen --ylen $ylen
mv data_*.txt swift/src
mv means.txt swift/src/means_init.txt
rm vars.txt

# Run offline Metropolis-Hastings to get mean and covariance parameters for each pixel
cd swift
./swift -e MHSampler -n $((num_param_samples + 5)) --burn-in $num_param_samples -i example/bsub_offline.blog -o src/bsub_offline.cpp 
cd src
g++ -Ofast -std=c++11 bsub_offline.cpp random/*.cpp -o bsub_offline -larmadillo
./bsub_offline > bsub_output.txt
mv bsub_output.txt ../../
# Clean up data files
rm data_*.txt
rm means_init.txt
cd ../../

# Parse means/covariances from output file and prepare parameters for Phase Two
python util/parse_output_file.py --input_file bsub_output.txt --output_dir mean_var_temp --query_type mean_var_offline --xlen $xlen --ylen $ylen
python util/make_param_txt.py --input_dir mean_var_temp --data_dir $data_dir --sequence_time_start $test_start_t --sequence_time_end $test_end_t --query_type read_test_data --xlen $xlen --ylen $ylen
cp mean_var_temp/means.txt mean_var_temp/vars.txt swift/src/
mv mean_var_temp/data_*.txt swift/src


# Phase Two: Load means/variances as initialization and getting output labels
# Make labeling scheme BLOG file 
python util/make_blog_file.py --input_name templates/bsub_offline_label.blog --output_name swift/example/bsub_offline_label.blog --query_type offline_label -t $training_end_t --xlen $xlen --ylen $ylen
cd swift
./swift -e MHSampler -n $((num_label_samples)) --burn-in $((num_label_burn_in)) --interval $((num_label_interval)) -i example/bsub_offline_label.blog -o src/bsub_offline_label.cpp
cd src
g++ -Ofast -std=c++11 bsub_offline_label.cpp random/*.cpp -o bsub_offline_label -larmadillo
./bsub_offline_label > bsub_output_label.txt
mv bsub_output_label.txt ../../
# Clean up data files
rm data_*.txt
rm means.txt vars.txt
cd ../../

# Parse labels from output log into images
mkdir $output_dir
python util/parse_output_file.py --input_file bsub_output_label.txt --output_dir $output_dir --query_type offline_sequence --xlen $xlen --ylen $ylen
mkdir $output_dir/blog
mv $output_dir/*.png $output_dir/blog

# Phase Three: Evaluation
python evaluation/run_opencv.py -v 2 -f $data_dir -o $output_dir/open_cv -s $test_start_t -e $test_end_t -x $xlen -y $ylen
python evaluation/labeled_image_to_mat.py -f $ground_truth_dir -o $output_dir/gt_mat -b 0 -x $xlen -y $ylen -s $test_start_t -e $test_end_t
python evaluation/labeled_image_to_mat.py -f $output_dir/blog -o $output_dir/blog_mat -b 0 -x $xlen -y $ylen -s $test_start_t -e $test_end_t
python evaluation/labeled_image_to_mat.py -f $output_dir/open_cv -o $output_dir/opencv_mat -b 0 -x $xlen -y $ylen -s $test_start_t -e $test_end_t
echo "Evaluating BLOG performance:"
python evaluation/evaluate_mats.py -p $output_dir/blog_mat -t $output_dir/gt_mat -g True -o $output_dir/blog_f1_per_frame.png
echo "Evaluating OpenCV performance:"
python evaluation/evaluate_mats.py -p $output_dir/opencv_mat -t $output_dir/gt_mat -g True -o $output_dir/opencv_f1_per_frame.png
