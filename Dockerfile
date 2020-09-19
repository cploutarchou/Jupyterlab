FROM python:alpine

LABEL maintainer="Christos Ploutarchou <cploutarchou@gmail.com>"

ARG build_date

LABEL org.label-schema.build-date=${build_date}
LABEL org.label-schema.name="pySpark Cluster on Docker - JupyterLab Image"
LABEL org.label-schema.description="JupyterLab image"
LABEL org.label-schema.url="https://github.com/cploutarchou/Jupyterlab"
LABEL org.label-schema.vcs-url="https://github.com/cploutarchou/Jupyterlab/blob/master/Dockerfile"
LABEL org.label-schema.schema-version="1.0"


# Install required packages
RUN apk add --update --no-cache curl jq py3-configobj py3-pip py3-setuptools python3 python3-dev libffi-dev nodejs
RUN apk add --update --virtual=.build-dependencies alpine-sdk nodejs ca-certificates musl-dev gcc make cmake g++ \
 gfortran libpng-dev freetype-dev libxml2-dev libxslt-dev
RUN apk add --update git

# Install Jupyter
RUN pip install jupyter
RUN pip install ipywidgets
RUN jupyter nbextension enable --py widgetsnbextension

# Install JupyterLab
RUN pip install jupyterlab && jupyter serverextension enable --py jupyterlab

ENV LANG=C.UTF-8

# Install Python Packages & Requirements
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Expose Jupyter port & cmd
EXPOSE 8888
RUN mkdir -p /opt/app/data
CMD jupyter lab --ip=* --port=8888 --no-browser --notebook-dir=/opt/app/data --allow-root