FROM quay.io/pypa/manylinux1_x86_64

LABEL description="A docker image for building portable Python linux binary wheels using modern GCC"
LABEL maintainer="tk@tkte.ch"

ARG GCC_VERSION=9.2.0
ARG GCC_PATH=/usr/local/gcc-$GCC_VERSION

RUN yum -y update && yum -y install \
    curl \
    bison \
    flex \
    && yum clean all

RUN cd /tmp \
    && curl -L -o gcc.tar.gz "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz" \
    && tar xf gcc.tar.gz \
    && cd /tmp/gcc-$GCC_VERSION \
    && contrib/download_prerequisites \
    && mkdir build \
    && cd build \
    && ../configure -v \
        --build=x86_64-linux-gnu \
        --host=x86_64-linux-gnu \
        --target=x86_64-linux-gnu \
        --prefix=/usr/local/gcc-$GCC_VERSION \
        --enable-checking=release \
        --enable-languages=c,c++,fortran \
        --disable-multilib \
        --program-suffix=-$GCC_VERSION \
    && make -j4 \
    && make install-strip \
    && cd /tmp \
    && rm -rf /tmp/gcc-$GCC_VERSION /tmp/gcc.tar.gz

ENV CFLAGS "-static-libstdc++"
ENV CC /usr/local/gcc-9.2.0/bin/gcc-9.2.0
ENV CXX /usr/local/gcc-9.2.0/bin/g++-9.2.0

RUN /opt/python/cp37-cp37m/bin/pip install -i https://pypi.tuna.tsinghua.edu.cn/simple cmake
RUN ln -s /opt/python/cp37-cp37m/bin/cmake /usr/bin/cmake
RUN ln -s /lib64/libuuid.so.1 /lib64/libuuid.so
