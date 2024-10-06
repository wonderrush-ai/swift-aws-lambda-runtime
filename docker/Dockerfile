ARG swift_version=5.10.0
ARG base_image=swift:$swift_version-amazonlinux2
FROM $base_image
# needed to do again after FROM due to docker limitation
ARG swift_version

# dependencies
RUN yum install -y wget perl-Digest-SHA
RUN yum install -y lsof dnsutils netcat-openbsd net-tools curl jq # used by integration tests
RUN yum install -y make

#RUN set -x \
 ### BUILD OpenSSL
 RUN wget --no-check-certificate -O /tmp/openssl-dude.tar.gz "https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz" 
 
 RUN tar -xvf /tmp/openssl-dude.tar.gz -C /tmp/ 
 RUN rm -rf /tmp/openssl-dude.tar.gz 
 
 RUN cd /tmp/openssl-dude 
 RUN ./Configure linux-x86_64 shared
 
 RUN make \
 && make test \
 && make install \
 && cd .. \
 && rm -rf openssl-dude
 
 ENV PATH /usr/local/ssl/bin:$PATH
 
#RUN yum install libssl-dev
#RUN mkdir /tmp/openssl
#RUN cd /tmp/openssl

#RUN git clone https://github.com/openssl/openssl.git
#RUN cd openssl 
#RUN /tmp/openssl/config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl '-Wl,-rpath,$(LIBRPATH)' 
#RUN make 
#RUN make install

#ENV LDFLAGS -L/usr/local/opt/openssl/lib
#ENV CPPFLAGS -I/usr/local/opt/openssl/include

# tools
RUN mkdir -p $HOME/.tools
RUN echo 'export PATH="$HOME/.tools:$PATH"' >> $HOME/.profile

# swiftformat (until part of the toolchain)

ARG swiftformat_version=0.50.1
RUN git clone --branch $swiftformat_version --depth 1 https://github.com/nicklockwood/SwiftFormat $HOME/.tools/swift-format
RUN cd $HOME/.tools/swift-format && swift build -c release
RUN ln -s $HOME/.tools/swift-format/.build/release/swiftformat $HOME/.tools/swiftformat
