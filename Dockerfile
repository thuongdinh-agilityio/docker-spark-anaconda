FROM gettyimages/spark

# ANACONDA 3

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-4.3.1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

# Install XGBoost library
RUN apt-get update --fix-missing && apt-get install -y gfortran libatlas-base-dev gfortran pkg-config \
            libfreetype6-dev libxft-dev libpng-dev libhdf5-serial-dev g++ \
            make patch lib32ncurses5-dev

USER root

# install gcc with openmp support in conda
RUN conda install -y gcc

# download and build xgboost
RUN cd /opt && \
  git clone --recursive https://github.com/dmlc/xgboost && \
  cd xgboost && \
  make -j4

# set environment var to python package for both python2 and python3
ENV PYTHONPATH /opt/xgboost/python-package
ENV PYTHONPATH $SPARK_HOME/python/lib/py4j-0.10.3-src.zip:$SPARK_HOME/python/:$PYTHONPATH

USER $NB_USER

# Install spark-sklearn

RUN pip install spark-sklearn

# Install Graphframes
ENV GRAPH_FRAMES_VERSION 0.4.0-spark2.1-s_2.11
ADD ./graphframes-dist/graphframes-${GRAPH_FRAMES_VERSION} $SPARK_HOME/graphframes
RUN cd $SPARK_HOME/graphframes && \
    ./build/sbt assembly && \
    mv $SPARK_HOME/graphframes/python/graphframes $SPARK_HOME/python/pyspark
ENV PYSPARK_SUBMIT_ARGS "--packages graphframes:graphframes:${GRAPH_FRAMES_VERSION} pyspark-shell"

WORKDIR $SPARK_HOME
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]