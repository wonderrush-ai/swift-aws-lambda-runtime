ARG swift_version=5.10.0
ARG base_image=swift:$swift_version-amazonlinux2
FROM $base_image
# needed to do again after FROM due to docker limitation
ARG swift_version

# dependencies
RUN yum install -y wget perl-Digest-SHA
RUN yum install -y lsof dnsutils netcat-openbsd net-tools curl jq # used by integration tests
RUN yum install -y make libuuid-devel 

# Step 2: Install dependencies required to build OpenSSL
RUN yum update -y && \
    yum install -y \
    gcc \
    gcc-c++ \
    make \
    perl-core \
    zlib-devel \
    wget \
    tar \
    && yum clean all

# Step 3: Define OpenSSL version and download it
ENV OPENSSL_VERSION=1.1.1v
RUN wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz && \
    tar -xzvf openssl-$OPENSSL_VERSION.tar.gz && \
    cd openssl-$OPENSSL_VERSION && \
    ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib && \
    make && \
    make install

# Step 4: Ensure the OpenSSL binary is accessible globally
RUN ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl

ENV PATH /usr/local/ssl/bin:$PATH

#ENV LDFLAGS=-L/usr/local/opt/openssl/lib
#ENV CPPFLAGS=-I/usr/local/opt/openssl/include

# Step 4: Set environment variables for OpenSSL headers and libraries
ENV OPENSSL_DIR=/usr/local/ssl
ENV CPPFLAGS="-I$OPENSSL_DIR/include"
ENV LDFLAGS="-L$OPENSSL_DIR/lib"
ENV PATH="$OPENSSL_DIR/bin:$PATH"
ENV PKG_CONFIG_PATH="$OPENSSL_DIR/lib/pkgconfig"

#Step 7: Install libdispatch and corelibs-foundation (which includes CoreFoundation)
RUN git clone https://github.com/apple/swift-corelibs-libdispatch.git && \
    cd swift-corelibs-libdispatch && \
    git checkout release/5.10 && \
    sh autogen.sh && \
    ./configure && \
    make && \
    make install 

RUN git clone https://github.com/apple/swift-corelibs-foundation.git && \
    cd swift-corelibs-foundation && \
    git checkout swift-5.7-branch && \
    swift build && \
    cp .build/release/*.so /usr/lib/


# tools
RUN mkdir -p $HOME/.tools
RUN echo 'export PATH="$HOME/.tools:$PATH"' >> $HOME/.profile
RUN echo 'ls $HOME'
RUN echo 'ls $OPENSSL_DIR/include'

# swiftformat (until part of the toolchain)

ARG swiftformat_version=0.50.1
RUN git clone --branch $swiftformat_version --depth 1 https://github.com/nicklockwood/SwiftFormat $HOME/.tools/swift-format
RUN cd $HOME/.tools/swift-format && swift build -c release
RUN ln -s $HOME/.tools/swift-format/.build/release/swiftformat $HOME/.tools/swiftformat
