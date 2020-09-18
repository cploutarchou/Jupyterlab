FROM python:alpine

LABEL maintainer="Christos Ploutarchou <cploutarchou@gmail.com>"

ARG build_date

LABEL org.label-schema.build-date=${build_date}
LABEL org.label-schema.name="pySpark Cluster on Docker - JupyterLab Image"
LABEL org.label-schema.description="JupyterLab image"
LABEL org.label-schema.url="https://github.com/cploutarchou/pyspark-cluster-with-hadoop-on-docker"
LABEL org.label-schema.vcs-url="https://github.com/cploutarchou/pyspark-cluster-with-hadoop-on-docker/build/docker/jupyterlab/Dockerfile"
LABEL org.label-schema.schema-version="1.0.0"


# Install required packages
RUN apk add --update --virtual=.build-dependencies alpine-sdk nodejs ca-certificates musl-dev gcc make cmake g++ \
    gfortran libpng-dev freetype-dev libxml2-dev libxslt-dev  gcc gfortran  py-pip build-base wget freetype-dev \
    libpng-dev openblas-dev

RUN apk add --update git

# Install Jupyter
RUN pip install jupyter
RUN pip install ipywidgets
RUN jupyter nbextension enable --py widgetsnbextension

# Install JupyterLab
RUN pip install jupyterlab && jupyter serverextension enable --py jupyterlab

# Additional packages for compatability (glibc)
ENV GLIBC_VERSION 2.32

RUN apk-install curl ca-certificates && \
    curl -O -L https://github.com/cploutarchou/Jupyterlab/blob/master/glibc/glibc-${GLIBC_VERSION}.apk -o glibc-${GLIBC_VERSION}.apk && \
    apk --allow-untrusted add glibc-${GLIBC_VERSION}.apk && \
    rm -f glibc-${GLIBC_VERSION}.apk && \
    rm -rf /root/.cache && \
    rm -rf /var/cache/apk/ && \
    apk version glibc && \
    ls /lib64/

ENV LANG=C.UTF-8

# Install Python Packages & Requirements (Done near end to avoid invalidating cache)
COPY requirements.txt requirements.txt
RUN python -m pip  install -r requirements.tx
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook
#
RUN python -m pip install jupyterthemes
RUN python -m pip install --upgrade jupyterthemes
RUN python -m pip install jupyter_contrib_nbextensions

# Expose Jupyter port & cmd
EXPOSE 8888
RUN mkdir -p /opt/app/data
CMD jupyter lab --ip=* --port=8888 --no-browser --notebook-dir=/opt/app/data --allow-root