# ROS noetic ( ubuntu focal)

        based on this http://wiki.ros.org/action/login/docker/Tutorials/Docker
# ros-dockerfile
ros docker, ros docker use nginx as proxy

Because ros.org provide the flexible way to deploy ros, we may need an one server run as master for other nodes connect.

            roscore

ros nodes will pub sub with centerlize ros master

inside docker we can run with ROS_IP=0.0.0.0 but got some warning 

we can try run ROS_IP=localhost then use nginx as proxy to forward to localhost

# roscore for rosmater with ROS_MASTER_URI=0.0.0.0:11311

                    docker build -f "roscore.Dockerfile" -t rosmaster-no-nginx .
                    docker run -d --restart always -it -p 11311:11311  --name rosmaster-no-nginx-test rosmaster-no-nginx

# roscore for rosmater with ROS_MASTER_URI=localhost:11311 and nginx as proxy

                    docker build -f "rocorenginx.Dockerfile" -t rosmaster-nginx .
                    docker run -d --restart always -it -p 11311:80  --name rosmaster-nginx-test rosmaster-nginx

# guide ros nodes connect to rosmaster ( rosmater run as docker container )

Eg: Your docker container run in computer with ip: 192.168.1.123

And you run docker above , the master uri: 192.168.1.123:11311

You have other computers or (other docker work as nodes) with ip: 192.168.1.124, 192.168.1.125

So you shoud do : 

                computer 1
                export ROS_IP=192.168.1.124
                export ROS_MASTER_URI=192.168.1.123:11311

                computer 2
                export ROS_IP=192.168.1.125
                export ROS_MASTER_URI=192.168.1.123:11311
