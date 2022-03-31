FROM centos:7.9.2009

# ENV http_proxy="http://xxxx:8080" https_proxy="http://xxxx:8080"
ENV LANG=en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /root

RUN yum install --nogpgcheck -y epel-release centos-release-scl \
    && yum install --nogpgcheck -y devtoolset-11-gcc-c++ wget bzip2 which git cmake3 openssh-server net-tools \
    && yum install --nogpgcheck -y htop libuv-devel.x86_64 zsh nc rh-python38-python.x86_64 zlib-devel.x86_64 python38-devel.x86_64

RUN echo "source /opt/rh/devtoolset-11/enable" >> /etc/bashrc
RUN echo "source /opt/rh/rh-python38/enable" >> /etc/bashrc

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' .zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME=obraun/g' .zshrc \
    && echo "source /opt/rh/devtoolset-11/enable" >> .zshrc \
    && echo "source /opt/rh/rh-python38/enable" >> .zshrc

RUN ssh-keygen -A \
    && mkdir /root/.ssh \
    && chmod 0700 /root/.ssh \
    && echo "root:root" | chpasswd \
    && ln -s /etc/ssh/ssh_host_ed25519_key.pub /root/.ssh/authorized_keys \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
ENTRYPOINT /usr/sbin/sshd -E /tmp/sshd.log && /bin/bash
EXPOSE 22

SHELL [ "/usr/bin/scl", "enable", "devtoolset-11" ]

COPY ./install_lib.sh /root/
RUN chmod 777 /root/install_lib.sh && /root/install_lib.sh full

WORKDIR /tmp
