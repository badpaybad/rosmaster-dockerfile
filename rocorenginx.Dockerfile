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

# # RUN apt-get -y update && apt-get -y install --no-install-recommends git nano apt-transport-https software-properties-common \
# #     wget unzip ca-certificates build-essential cmake git 
# # RUN apt-get -y install libtbb-dev libatlas-base-dev libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev 
# # RUN apt-get -y install libv4l-dev libtheora-dev libvorbis-dev libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev libavresample-dev 
# # RUN apt-get -y install x264 libtesseract-dev libgdiplus libc6-dev libc6-dev && apt-get -y clean && rm -rf /var/lib/apt/lists/*

# #RUN apt -y update && apt -y install ros-noetic-desktop-full
# RUN apt -y update && RUN apt install -y ros-noetic-ros-base ros-noetic-joy ros-noetic-teleop-twist-joy ros-noetic-teleop-twist-keyboard ros-noetic-laser-proc ros-noetic-rgbd-launch ros-noetic-depthimage-to-laserscan ros-noetic-rosserial-arduino ros-noetic-rosserial-python ros-noetic-rosserial-server ros-noetic-rosserial-client ros-noetic-rosserial-msgs ros-noetic-amcl ros-noetic-map-server ros-noetic-move-base ros-noetic-urdf ros-noetic-xacro ros-noetic-compressed-image-transport ros-noetic-rqt-image-view ros-noetic-gmapping ros-noetic-navigation ros-noetic-interactive-markers ros-noetic-hls-lfcd-lds-driver python3-rostopic ros-noetic-robot-state-publisher python3-roslaunch ros-noetic-cv-bridge

RUN apt -y update && apt install -y ros-noetic-ros-core

RUN apt-get update && apt-get install --no-install-recommends -y build-essential \
    python3-rosdep python3-rosinstall python3-vcstools 

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
#RUN echo "export NUM_WORKERS=nproc --all" >> roscore.sh
RUN echo "export NUM_WORKERS=16" >> roscore.sh
RUN echo "export ROS_MASTER_URI=http://localhost:11311" >> roscore.sh
RUN echo "export ROS_HOSTNAME=localhost" >> roscore.sh
RUN echo "export TURTLEBOT3_MODEL=burger" >> roscore.sh
RUN echo "export TB3_MODEL=burger" >> roscore.sh
RUN echo "source /opt/ros/noetic/setup.bash --" >> roscore.sh
RUN echo "exec roscore & nginx -g 'daemon off;'" >> roscore.sh

# # #/etc/nginx/conf.d
RUN apt update -y && apt -y install nginx
RUN chmod 777 -R /etc/nginx/conf.d
RUN rm -rf /etc/nginx/sites-enabled/default
RUN echo "server {" >> "/etc/nginx/conf.d/default.conf"
RUN echo "    listen 80;" >> "/etc/nginx/conf.d/default.conf"
RUN echo "    server_name _;" >> "/etc/nginx/conf.d/default.conf"
RUN echo "    location / {" >> "/etc/nginx/conf.d/default.conf"
RUN echo "      proxy_pass http://localhost:11311;" >> "/etc/nginx/conf.d/default.conf"
RUN echo "    }" >> "/etc/nginx/conf.d/default.conf"
RUN echo "}" >> "/etc/nginx/conf.d/default.conf"


RUN chmod 777 -R /app

RUN apt  -y clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/app/roscore.sh"]
CMD ["bash"]

#docker build -f "rocorenginx.Dockerfile" -t rosmaster-nginx .
#docker run -d --restart always -it -p 11311:80  --name rosmaster-nginx-test rosmaster-nginx
