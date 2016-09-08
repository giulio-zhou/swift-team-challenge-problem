==================
   Instructions
==================
The setup and execution instructions listed in this README have been tested
and verified to work on an Amazon EC2 Ubuntu 14.04 with the following specs:
  * 30GB of disk space
  * 32GB of RAM
  * 8 vCPU's
Specifically, the instance used was an m4.2xlarge with the description
"Ubuntu Server 14.04 LTS (HVM), SSD Volume Type - ami-d732f0b7".

To install the armadillo, BLOG and Python dependencies, run the setup script.
    ./setup.sh
To run an end-to-end BLOG example, execute the run_experiment script.
    ./run_experiment.sh [data directory] [xlen] [ylen] [training timestep start] [training timestep end] \
                        [test timestep start] [test timestep end] [output directory] [ground truth image directory]
To run the entire Stuttgart example, execute the run_stuttgart_example script.
    ./run_stuttgart_example.sh [directory to store data]
    NOTE: If you would like to run the example in the background (perhaps via nohup), make sure to run the 
          setup script first; failing to do so will cause the program to skip all of the setup steps and 
          create other issues along the way as well.
