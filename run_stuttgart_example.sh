#!/bin/bash
./setup.sh
./fetch_stuttgart_data.sh $1
./run_submission.sh $1/SABS/Test/Basic 240 180 0 150 0 150 output_dir $1/SABS/GT
