## Introduction

This project contains a set of patches and scripts to compile and run ROS Kinetic onboard a Pepper robot. It runs OctoMap on it.

## Pre-requirements

Download and extract the [NaoQi C++ framework](http://doc.aldebaran.com/2-5/index_dev_guide.html) and Softbanks's crosstool chain and point the `AL_DIR` and `ALDE_CTC_CROSS` environment variables to their respective paths:

```
export AL_DIR=/home/NaoQi  <-- Or wherever you installed NaoQi
export ALDE_CTC_CROSS=$AL_DIR/ctc-linux64-atom-2.5.2.74
```

Because the ctc 2.5.2.74 has been removed from SoftBank's official downloads you may need to use the ctc 2.5.10.7 instead:

```
export ALDE_CTC_CROSS=$AL_DIR/ctc-linux64-atom-2.5.10.7
```

## Prepare cross-compiling environment

We're going to use Docker to set up a container that will compile all the tools for cross-compiling ROS and all of its dependencies. Go to https://www.docker.com/community-edition to download it and install it for your Linux distribution.


1. Clone the project's repository

```
$ git clone https://github.com/Maelic/ros2_pepper.git
$ cd ros2_pepper
```

## ROS 

### Prepare the requirements for ROS 1

The following script will create a Docker image and compile Python interpreters suitable for both the host and the robot.

```
./prepare_requirements_ros1.sh
```

### Build ROS 1 dependencies

Before we actually build ROS for Pepper, there's a bunch of dependencies we'll need to cross compile which are not available in Softbank's CTC:

- console_bridge
- uuid
- poco
- tinyxml2
- urdfdom and urdfdom_headers
- SDL and SDL image
- hdf5
- bullet
- yaml-cpp
- eigen3
- qhull
- flann
- pcl
- octomap

```
./build_ros1_dependencies.sh
```

### Build ROS Kinetic

Finally! Type the following, go grab a coffee and after a while you'll have an entire base ROS distro built for Pepper.

```
./build_ros1.sh
```

### Copy ROS and its dependencies to the robot

By now you should have the following inside .ros-root in the current directory:

- Python 2.7 built for Pepper (System/Python-2.7.17)
- Python 3.8 built for Pepper (System/Python-3.8.1)
- All the dependencies required by ROS (System/ros1_dependencies)
- A ROS workspace with ROS Kinetic built for Pepper (System/ros1_inst)
- A helper script that will set up the ROS workspace in the robot (System/setup_ros1_pepper.bash)

We're going to copy these to the robot, assuming that your robot is connected to your network, type the following:

```
$ scp -r System.tar.gz nao@IP_ADDRESS_OF_YOUR_ROBOT:ROS
```

unpack it on the robot again.

### Run ROS Kinetic with octomap from inside Pepper

Now that we have it all in the robot, let's give it a try:

*SSH into the robot*

```
$ ssh nao@IP_ADDRESS_OF_YOUR_ROBOT
```

*(IN THE ROBOT): Source (not run) the setup script*

```
$ source System/setup_ros1_pepper.bash
```

*(IN THE ROBOT): Start the launch file for octomap*

```
$ roslaunch  ~/System/launch/pepper_octomap.launch 
```

*(ON THE EXTERNAL COMPUTER CONNECTED TO THE ROBOT): launch Rviz and visualized the data published in real time*

```
$ export ROS_MASTER_URI=http://IP_ADDRESS_OF_YOUR_ROBOT:11311
$ export ROS_IP=IP_ADDRESS_OF_YOUR_ROBOT
$ rviz rviz
```
You should be able to see the built map under the topic "projected-map" (Add -> By Topic -> projected_map).


## Citations and Sources
This repo is based on https://github.com/esteve/ros2_pepper of Esteve Fernandez.