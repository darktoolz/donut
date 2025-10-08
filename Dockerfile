ARG SOURCE_DATE_EPOCH=0

FROM debian:testing-slim AS builder
ARG SOURCE_DATE_EPOCH

RUN mkdir -p /workdir
RUN chmod ugo+wrx /workdir

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install --no-install-recommends --no-install-suggests -y \
      ca-certificates zip wget curl xml2 python3 ruby \
      mingw-w64 g++ go libssl-dev build-essential \
      git make pkg-config automake libtool autotools-dev

FROM builder AS donut
ARG SOURCE_DATE_EPOCH

WORKDIR /opt
COPY . .
RUN git submodule update --init --recursive
RUN make -f Makefile.mingw && make -f Makefile.gcc

RUN apt remove git autotools-dev automake autoconf pkg-config
RUN rm -rf .git .github /var/lib/apt /var/cache /var/log/apt /var/log/dpkg* \
        /var/lib/dpkg* /usr/libexec/dpkg* /usr/share/doc /usr/share/man

WORKDIR /workdir
ENV PATH=$PATH:/opt
ENTRYPOINT ["/opt/donut"]
