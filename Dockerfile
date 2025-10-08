ARG SOURCE_DATE_EPOCH=0

FROM debian:testing AS builder
ARG SOURCE_DATE_EPOCH

RUN mkdir -p /workdir
RUN chmod ugo+wrx /workdir

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install --no-install-recommends --no-install-suggests -y \
      mingw-w64 zip build-essential perl python3 xml2 pkg-config automake \
      libtool autotools-dev make g++ git ruby wget libssl-dev

FROM builder AS donut
ARG SOURCE_DATE_EPOCH

WORKDIR /opt
COPY . .
RUN git submodule update --init --recursive
RUN make -f Makefile.mingw && make -f Makefile.gcc
RUN ls /opt

WORKDIR /workdir
ENV PATH=$PATH:/opt
ENTRYPOINT ["/opt/donut"]
