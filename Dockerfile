FROM centos:7.9.2009

# ENV http_proxy="http://192.168.1.104:10809" https_proxy="http://192.168.1.104:10809"
ENV LANG=en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# RUN cd /etc/yum.repos.d/ && rm -rf CentOS-Base.repo
# RUN cd /etc/yum.repos.d/ && curl -O http://mirrors.aliyun.com/repo/Centos-7.repo
# RUN cd /etc/yum.repos.d/ && mv Centos-7.repo CentOS-Base.repo && yum clean all && yum makecache -y

WORKDIR /root
RUN yum update --nogpgcheck -y \
    && yum install --nogpgcheck -y https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm \
    && yum install --nogpgcheck -y epel-release centos-release-scl \
    && yum install --nogpgcheck -y devtoolset-11-gcc-c++ wget bzip2 which git cmake3 openssh-server tig net-tools automake libuuid-devel.x86_64 rapidjson-devel.noarch \
    && yum install --nogpgcheck -y htop libuv-devel.x86_64 zsh nc rh-python38-python.x86_64 zlib-devel.x86_64 rh-python38-python-devel.x86_64 sudo mysql++-devel.x86_64 rapidjson-devel.noarch

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

RUN git config --global color.status auto \
    && git config --global color.diff auto \
    && git config --global color.branch auto \
    && git config --global color.interactive auto

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' .zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME=obraun/g' .zshrc \
    && echo "source /opt/rh/devtoolset-11/enable" >> .zshrc \
    && echo "source /opt/rh/rh-python38/enable" >> .zshrc
