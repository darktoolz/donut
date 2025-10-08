ARG SOURCE_DATE_EPOCH=0

FROM debian:testing-slim AS sys
ARG SOURCE_DATE_EPOCH

RUN mkdir -p /workdir
RUN chmod ugo+wrx /workdir

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install --no-install-recommends --no-install-suggests -y \
      ca-certificates zip wget curl xml2 python3 ruby \
      mingw-w64 g++ golang libssl-dev build-essential \
      git make pkg-config automake libtool autotools-dev

FROM sys AS builder
ARG SOURCE_DATE_EPOCH

WORKDIR /opt
COPY . .
RUN git submodule update --init --recursive
RUN make -f Makefile.mingw && make -f Makefile.gcc
RUN cd generators/go-donut && go build -o ../../go-donut

RUN apt-get remove -y git autotools-dev automake autoconf pkg-config golang mingw-w64 g++
RUN rm -rf generators .git .github /var/lib/apt /var/cache /var/log/apt /var/log/dpkg* \
        /var/lib/dpkg* /usr/libexec/dpkg* /usr/share/doc /usr/share/man /var/log/alt* \
        /root/.cache /root/.config /root/go /usr/lib/go-1.24 /usr/share/go-1.24

FROM scratch
COPY --from=builder / /
ARG SOURCE_DATE_EPOCH

WORKDIR /workdir
ENV PATH=$PATH:/opt
ENTRYPOINT ["/opt/donut"]
