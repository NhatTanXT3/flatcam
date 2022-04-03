# Launch FlatCAM container (from directory with FlatCAM files)
# docker run -it --rm --net host --env DISPLAY  -d $(pwd):/home/flatcam/files flatcam

# POSIX compatible (Linux/Unix) base image
FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

# Define local arguments
ARG FLATCAM_VERSION="FlatCAM-8.5"
# ARG FLATCAM_CHECKSUM="4a758880b5122ff146c22a7ad0fa563f"

# Establish development environment (from `setup-ubuntu.sh`)
RUN apt-get update --quiet \
    && apt-get install --assume-yes --no-install-recommends --quiet \
     libfreetype6 \
     libfreetype6-dev \
     libgeos-dev \
     libpng-dev \
     python-dev \
     python-matplotlib \
     python-numpy \
     python-qt4 \
     python-scipy \
     python-setuptools \
     python-simplejson \
     python-shapely \
     python-tk \
     libspatialindex-dev \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update  && apt-get install -y --no-install-recommends\
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python /usr/lib/python2.7/dist-packages/easy_install.py -U distribute
RUN apt-get update && apt-get install -y --no-install-recommends \
    python-pip \
    && rm -rf /var/lib/apt/lists/*

#freeze version that works for this flatcam
RUN pip install --upgrade pip && pip install --upgrade \
matplotlib==2.2.5 \
Rtree==0.9.7 \
Shapely==1.7.1 \
svg.path==4.1 

# Create Non-Root User
RUN addgroup --gid 1000 flatcam \
    && adduser --disabled-password --gecos \"\" --home /home/flatcam \
     --ingroup flatcam --uid 1000 flatcam 

WORKDIR /home/flatcam
USER flatcam

COPY . /home/flatcam/${FLATCAM_VERSION}/

ENV QT_X11_NO_MITSHM=1
ENV FLATCAM_VERSION=${FLATCAM_VERSION}
CMD python /home/flatcam/${FLATCAM_VERSION}/FlatCAM.py
