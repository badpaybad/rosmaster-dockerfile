FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS base

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV ROS_DISTRO noetic
ENV NUM_WORKERS=16

RUN cat /etc/os-release

# # setup timezone
# RUN echo 'Etc/UTC' > /etc/timezone && \
#     ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
#     apt-get update && \
#     apt-get install -q -y --no-install-recommends tzdata && \
#     rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y --no-install-recommends \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

RUN apt -y update
RUN  apt install -y  git curl wget unzip     build-essential cmake  libgdiplus    dphys-swapfile  python3-pip
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc |  apt-key add -

RUN apt -y update && apt install -y ros-noetic-ros-core

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential python3-rosdep python3-rosinstall python3-vcstools 

# bootstrap rosdep
RUN rosdep init && rosdep update --rosdistro $ROS_DISTRO

# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends ros-noetic-ros-base 

RUN chmod 777 -R /opt/ros/noetic

RUN apt update -y &&  apt -y install  htop nano iputils-ping

WORKDIR /app

RUN chmod 777 -R /app

#http
EXPOSE 11311 
EXPOSE 11312
EXPOSE 80 
#https
EXPOSE 443

RUN echo "#!/bin/bash" >> roscore.sh
RUN echo "set -e" >> roscore.sh

RUN echo "export ROS_IP=0.0.0.0" >> roscore.sh
RUN echo "export NUM_WORKERS=16" >> roscore.sh
RUN echo "export ROS_MASTER_URI=http://0.0.0.0:11311" >> roscore.sh

RUN echo "export TURTLEBOT3_MODEL=burger" >> roscore.sh
RUN echo "export TB3_MODEL=burger" >> roscore.sh
RUN echo "source /opt/ros/noetic/setup.bash --" >> roscore.sh
RUN echo "exec roscore" >> roscore.sh


RUN chmod 777 -R /app

RUN apt  -y clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/app/roscore.sh"]
CMD ["bash"]


#docker build -f "roscore.Dockerfile" -t rosmaster-no-nginx .
#docker run -d --restart always -it -p 11311:11311  --name rosmaster-no-nginx-test rosmaster-no-nginx
