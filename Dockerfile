FROM osrf/ros:humble-desktop

RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    python3-colcon-common-extensions \
    cmake \
    build-essential \
    libeigen3-dev \
    libopencv-dev \
    ros-humble-pcl-ros \
    ros-humble-pcl-conversions \
    libpcl-dev \
    ros-humble-tf2-ros \
    ros-humble-tf2-eigen \
    ros-humble-tf2-geometry-msgs \
    ros-humble-message-filters \
    ros-humble-geometry-msgs \
    ros-humble-nav-msgs \
    ros-humble-sensor-msgs \
    && rm -rf /var/lib/apt/lists/*

# ANYbotics grid_map
RUN mkdir -p /opt/anybotics_ws/src && \
    cd /opt/anybotics_ws/src && \
    git clone https://github.com/anybotics/grid_map.git --branch humble && \
    apt-get update && \
    rosdep update && \
    cd /opt/anybotics_ws && \
    . /opt/ros/humble/setup.sh && \
    rosdep install -y --ignore-src --from-paths src && \
    colcon build --symlink-install && \
    rm -rf /var/lib/apt/lists/*

RUN printf '#!/bin/bash\n\
set -e\n\
source /opt/ros/humble/setup.sh\n\
source /opt/anybotics_ws/install/setup.bash\n\
if [ -d /ros2_ws/src ]; then\n\
  cd /ros2_ws\n\
  rosdep install --from-paths src --ignore-src -y || true\n\
  colcon build --symlink-install\n\
  source /ros2_ws/install/setup.bash\n\
fi\n\
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp\n\
exec "$@"\n' > /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /ros2_ws
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]