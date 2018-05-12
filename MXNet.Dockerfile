FROM elixir:latest

RUN apt-get update \
  && apt-get install -y wget python gcc \
  && wget https://bootstrap.pypa.io/get-pip.py \
  && python get-pip.py \
  && pip install mxnet==1.2.0b20180512 \
  && apt-get install -y  graphviz \
  && pip install graphviz \
  && pip install Pillow \
  && pip install onnx
