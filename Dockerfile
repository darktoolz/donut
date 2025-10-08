FROM debian:testing

RUN apt-get update && apt-get upgrade
RUN apt-get install --no-install-recommends --no-install-suggests -y \
      mingw-w64 zip build-essential perl python3 xml2 pkg-config automake \
      libtool autotools-dev make g++ git ruby wget libssl-dev

WORKDIR /opt
COPY . .
#RUN git clone https://github.com/TheWover/donut.git
RUN git submodule update --init --recursive
#WORKDIR /opt
RUN make -f Makefile.gcc
#RUN cp -f donut hash encrypt inject inject_local exe2h /usr/bin
RUN mkdir -p /workdir
WORKDIR /workdir
RUN chmod ugo+wrx /workdir
RUN ls /opt
ENV PATH=$PATH:/opt
ENTRYPOINT ["/opt/donut"]
