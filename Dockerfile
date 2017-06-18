FROM ubuntu:16.04
RUN apt-get update -y && \
    apt-get install -y gcc g++ wget python-dev
# Install Go
RUN wget -O go.tgz https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz && \
  tar -C /usr/local -xzf go.tgz && \
  mkdir /root/gopath && \
  rm go.tgz
ENV GOROOT=/usr/local/go GOPATH=/root/gopath
# should not be in the same line with GOROOT definition, otherwise docker build could not find GOROOT.
ENV PATH=${PATH}:${GOROOT}/bin
