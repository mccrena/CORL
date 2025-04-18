FROM nvidia/cuda:11.3.1-runtime-ubuntu20.04
WORKDIR /workspace

# python, dependencies for mujoco-py, from https://github.com/openai/mujoco-py
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3-pip \
    build-essential \
    patchelf \
    curl \
    git \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglew-dev \
    libosmesa6-dev \
    software-properties-common \
    net-tools \
    vim \
    virtualenv \
    wget \
    xpra \
    xserver-xorg-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python
# installing mujoco distr
RUN mkdir -p /root/.mujoco \
    && wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O mujoco.tar.gz \
    && tar -xf mujoco.tar.gz -C /root/.mujoco \
    && rm mujoco.tar.gz
ENV LD_LIBRARY_PATH /root/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}

# installing poetry & env setup, mujoco_py compilation
# 修改为
COPY requirements/requirements.txt requirements.txt
# 先安装较低版本的Cython
RUN pip install Cython==0.29.32
# 安装要求的typing-extensions版本
RUN pip install typing-extensions\<4.6.0
# 然后安装其他依赖
RUN pip install -r requirements.txt
# 如果仍有问题，尝试重新安装mujoco_py
RUN pip uninstall -y mujoco_py && pip install mujoco_py==2.1.2.14 --no-cache-dir
# 测试导入
RUN python -c "import mujoco_py"

COPY . /workspace/CORL/
