ARG swift_version=5.10.0
ARG base_image=swift:$swift_version-amazonlinux2
FROM $base_image
# needed to do again after FROM due to docker limitation
ARG swift_version

# dependencies
RUN yum install -y wget perl-Digest-SHA
RUN yum install -y lsof dnsutils netcat-openbsd net-tools curl jq # used by integration tests

RUN mkdir /tmp/openssl
RUN cd /tmp/openssl
RUN wget https://www.openssl.org/source/openssl-1.1.1s.tar.gz
RUN tar xzvf openssl-1.1.1s.tar.gz
RUN cd openssl-1.1.1s && ./config --prefix=/usr/local/openssl11 --openssldir=/usr/local/openssl11 shared zlib && make && sudo make install

# tools
RUN mkdir -p $HOME/.tools
RUN echo 'export PATH="$HOME/.tools:$PATH"' >> $HOME/.profile

# swiftformat (until part of the toolchain)

ARG swiftformat_version=0.50.1
RUN git clone --branch $swiftformat_version --depth 1 https://github.com/nicklockwood/SwiftFormat $HOME/.tools/swift-format
RUN cd $HOME/.tools/swift-format && swift build -c release
RUN ln -s $HOME/.tools/swift-format/.build/release/swiftformat $HOME/.tools/swiftformat
