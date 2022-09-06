# ROS noetic ( ubuntu focal)

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