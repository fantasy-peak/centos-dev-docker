FROM centos:7.9.2009

# ENV http_proxy="http://xxxx:8080" https_proxy="http://xxxx:8080"

WORKDIR /root

RUN yum install --nogpgcheck -y epel-release centos-release-scl \
    && yum install --nogpgcheck -y devtoolset-11-gcc-c++ wget bzip2 which git cmake3 openssh-server net-tools \
    && yum install --nogpgcheck -y htop libuv-devel.x86_64 zsh

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' .zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME=obraun/g' .zshrc

RUN ssh-keygen -A \
    && mkdir /root/.ssh \
    && chmod 0700 /root/.ssh \
    && echo "root:root" | chpasswd \
    && ln -s /etc/ssh/ssh_host_ed25519_key.pub /root/.ssh/authorized_keys
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
ENTRYPOINT /usr/sbin/sshd -E /tmp/sshd.log && /bin/bash
EXPOSE 22

RUN echo "source /opt/rh/devtoolset-11/enable" >> /etc/bashrc
RUN source /etc/bashrc
SHELL [ "/usr/bin/scl", "enable", "devtoolset-11"]

WORKDIR /tmp

RUN git clone https://github.com/redis/hiredis.git \
    && cd hiredis \
    && mkdir build && cd build \
    && cmake3 .. -DCMAKE_INSTALL_PREFIX=/usr \
    && make install \
    && cd ../.. && rm -rf hiredis

ARG BOOST_VERSION=1.78.0
ARG BOOST_DIR=boost_1_78_0
ENV BOOST_VERSION ${BOOST_VERSION}

RUN wget http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/${BOOST_DIR}.tar.bz2 \
    && tar --bzip2 -xf ${BOOST_DIR}.tar.bz2 \
    && cd ${BOOST_DIR} \
    && ./bootstrap.sh -with-toolset=gcc \
    && ./b2 --without-python --prefix=/usr -j 8 link=shared runtime-link=shared install \
    && cd .. && rm -rf ${BOOST_DIR} ${BOOST_DIR}.tar.bz2 \
    && ldconfig

RUN git clone https://github.com/redis/redis.git \
    && cd redis \
    && make -j 8 \
    && make install \
    && cd .. && rm -rf redis
