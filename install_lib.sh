#!/bin/bash

function start_install_redis_func() {
    git clone https://github.com/redis/redis.git
    cd redis
    make -j 8
    make install
    cd .. && rm -rf redis
}

function start_install_boost_func() {
    BOOST_VERSION=1.78.0
    BOOST_DIR=boost_1_78_0

    wget http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/${BOOST_DIR}.tar.bz2
    tar --bzip2 -xf ${BOOST_DIR}.tar.bz2
    cd ${BOOST_DIR}
    ./bootstrap.sh -with-toolset=gcc
    ./b2 --without-python --prefix=/usr -j 8 link=static runtime-link=shared install
    cd .. && rm -rf ${BOOST_DIR} ${BOOST_DIR}.tar.bz2
    ldconfig
}

function start_install_hiredis_func() {
    git clone https://github.com/redis/hiredis.git
    cd hiredis
    mkdir build && cd build
    cmake3 .. -DCMAKE_INSTALL_PREFIX=/usr
    make install
    cd ../.. && rm -rf hiredis
}

function start_install_openssl() {
    wget http://www.openssl.org/source/openssl-1.1.1g.tar.gz --no-check-certificate
    tar zxvf openssl-1.1.1g.tar.gz
    cd openssl-1.1.1g
    ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-shared zlib-dynamic
    make -j 8
    make install
    cd .. && rm -rf openssl-1.1.1g.tar.gz openssl-1.1.1g
}

function start_work() {
    if [ $1 == "redis" ]; then
        start_install_redis_func
    elif [ $1 == "boost" ];then
        start_install_boost_func
    elif [ $1 == "hiredis" ];then
        start_install_hiredis_func
    elif [ $1 == "openssl" ];then
        start_install_openssl
    fi
}

string=$1
if [ $string == "full" ]; then
    string="hiredis,redis,boost,openssl"
fi

array=(${string//,/ })

for var in ${array[@]}; do
    start_work $var
done
