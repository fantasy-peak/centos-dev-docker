FROM centos:7.9.2009

# ENV http_proxy="http://xxxx" https_proxy="http://xxxx"
ENV LANG=en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# RUN cd /etc/yum.repos.d/ && rm -rf CentOS-Base.repo
# RUN cd /etc/yum.repos.d/ && curl -O http://mirrors.aliyun.com/repo/Centos-7.repo
# RUN cd /etc/yum.repos.d/ && mv Centos-7.repo CentOS-Base.repo && yum clean all && yum makecache -y

WORKDIR /root

RUN yum install --nogpgcheck -y epel-release centos-release-scl \
    && yum install --nogpgcheck -y devtoolset-11-gcc-c++ wget bzip2 which git cmake3 openssh-server net-tools \
    && yum install --nogpgcheck -y htop libuv-devel.x86_64 zsh nc rh-python38-python.x86_64 zlib-devel.x86_64 python38-devel.x86_64 sudo

RUN ssh-keygen -A \
    && mkdir /root/.ssh \
    && chmod 0700 /root/.ssh \
    && echo "root:root" | chpasswd \
    && ln -s /etc/ssh/ssh_host_ed25519_key.pub /root/.ssh/authorized_keys \
    && echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
ENTRYPOINT sudo /usr/sbin/sshd -E /tmp/sshd.log && /bin/bash
EXPOSE 22

RUN useradd fantasy && echo "fantasy:fantasy" | chpasswd
RUN mkdir -p /home/fantasy && chown -R fantasy:fantasy /home/fantasy
RUN chmod u+w /etc/sudoers
RUN echo 'fantasy ALL=NOPASSWD:ALL' >> /etc/sudoers

USER fantasy
WORKDIR /home/fantasy

RUN echo -e "\n" | ssh-keygen -N "" &> /dev/null
RUN cat .ssh/id_rsa.pub > .ssh/authorized_keys

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' .zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME=obraun/g' .zshrc \
    && echo "source /opt/rh/devtoolset-11/enable" >> .zshrc \
    && echo "source /opt/rh/rh-python38/enable" >> .zshrc \
    && echo "source /opt/rh/rh-python38/enable" >> .bashrc \
    && echo "source /opt/rh/devtoolset-11/enable" >> .bashrc
