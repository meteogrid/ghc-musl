FROM multiarch/alpine:x86-edge

ENV GHC_VERSION      7.10.3
ENV PATCHELF_VERSION 0.8
ENV CABAL_VERSION    1.22.6.0

WORKDIR /tmp

RUN : "Layer 0: Install development tools" && \
    apk --update add curl xz alpine-sdk perl gmp-dev file gmp openssh openssl zlib-dev strace vim less jq ncurses-dev bash autoconf pcre-dev && \
    : Install patchelf && \
    curl -L https://nixos.org/releases/patchelf/patchelf-$PATCHELF_VERSION/patchelf-$PATCHELF_VERSION.tar.bz2 | tar xj && \
    cd patchelf-$PATCHELF_VERSION && \
    ./configure && \
    make install

COPY build.mk ./
RUN : "Layer 1: fully working basic GHC in /usr/local" && \
    mkdir /opt && \
    curl -L https://s3-eu-west-1.amazonaws.com/sigym4/thirdparty/ghc-7.8.4-x86_64-unknown-linux-musl.tar | tar xJ -C / && \
    curl -L https://www.haskell.org/ghc/dist/$GHC_VERSION/ghc-$GHC_VERSION-src.tar.bz2 | tar xj && \
    cd ghc-$GHC_VERSION && \
    cp -v /tmp/build.mk mk/build.mk && \
    PATH=/opt/ghc-cross/bin:$PATH ./configure && \
    : patch libffi bug && \
    sed -i 's,chmod,sed -i s/__gnu_linux__/1/ libffi/build/src/closures.c \&\& chmod,' libffi/ghc.mk && \
    make -j8 && \
    make binary-dist

RUN : Install the ghc binary distribution to minimize docker layer size && \
    cd /tmp && \
    tar xjf ghc-$GHC_VERSION/ghc-$GHC_VERSION-i386-unknown-linux.tar.bz2 --transform "s/^ghc-${GHC_VERSION}/ghc-binary-dist/" && \
    cd ghc-binary-dist && \
    ./configure && \
    : musl ld requires --no-pie to work for some reason with ghc && \
    sed -i '/C\ compiler\ link/{ s/""/"--no-pie"/ }' settings && \
    make install && \
    : Clean up to keep the image small && \
    rm -rf /tmp/* /opt/ghc-cross

RUN : Check that we can interpret a haskell program && \
    (echo "main=return ()" | runhaskell) && \
    : "Yes we can"

ENV PATH=/root/.cabal/bin:$PATH
RUN : "Layer 2: cabal-install, but only the binary, no executables" && \
    curl -L https://hackage.haskell.org/package/cabal-install-$CABAL_VERSION/cabal-install-$CABAL_VERSION.tar.gz | tar xz && \
    cd cabal-install-$CABAL_VERSION && \
    sed -i 's/export TMPDIR=.*/export TMPDIR=$(mktemp -t cabal-XXXXXX -d)/' bootstrap.sh && \
    EXTRA_CONFIGURE_OPTS=--disable-library-profiling ./bootstrap.sh

# Files For stack
COPY entrypoint.sh /
COPY groupadd /usr/sbin/groupadd
COPY useradd /usr/sbin/useradd

WORKDIR /root/.cabal
RUN : "Layer 3: install stack" && \
    cabal update && \
    cabal install --global cryptonite -f-support_rdrand && \
    cabal install --global stack && \
    : Clean up to keep the image small && \
    rm -rf /tmp/*

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
