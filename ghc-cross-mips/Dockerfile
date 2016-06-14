FROM vicamo/debian:jessie-mips

ENV TARGET mips-unknown-linux-musl

RUN apt-get update
RUN apt-get install -y musl-tools build-essential wget ghc libncurses-dev \
                       autoconf ca-certificates autotools-dev binutils
# file

WORKDIR /tmp
RUN wget https://www.haskell.org/ghc/dist/7.10.3/ghc-7.10.3-src.tar.bz2
RUN tar xvfj ghc-7.10.3-src.tar.bz2
WORKDIR /tmp/ghc-7.10.3

COPY build.mk /tmp/ghc-7.10.3/mk/build.mk
RUN ln -s $(which readelf) /usr/bin/${TARGET}-readelf
RUN ./configure --target=${TARGET} \
                --with-gcc=musl-gcc \
                --with-ld=ld \
                --with-nm=nm \
                --with-ar=ar \
                --with-ranlib=ranlib \
                --enable-unregisterised \
                --prefix=/opt/ghc-cross


# update config.sub in libffi, so it supports $TARGET
RUN sed -i 's,chmod,cp /usr/share/misc/config.sub libffi/build/config.sub \&\& chmod,' libffi/ghc.mk

# then just build it!
RUN make -j$(grep -c processor /proc/cpuinfo)

RUN make install

WORKDIR /tmp
RUN rm -rf /tmp/*
