#!/bin/bash -xe
echo '-----BEGIN RSA PRIVATE KEY-----' | tee /opt/jenkinsssh_id_rsa
echo {{user `jenkins_ssh_key`}} | sed -e 's/[[:blank:]]\\+/\\n/g' | tee -a /opt/jenkinsssh_id_rsa
echo '-----END RSA PRIVATE KEY-----' | tee -a /opt/jenkinsssh_id_rsa

mv /tmp/*.repo /etc/yum.repos.d/
yum install -y deltarpm rsync 
yum-config-manager --disable openlogic
yum --releasever=7 update -y
yum install -y cloud-init epel-release libselinux-python centos-release-scl

yum install -y python3-pip
pip3 install --upgrade setuptools
pip3 install --upgrade pip
pip3 install --upgrade docker-compose

curl --location https://rpm.nodesource.com/setup_12.x | sudo bash -
rpm --import https://repo.ius.io/RPM-GPG-KEY-IUS-7
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

yum install -y nodejs postgresql11

npm install npm@latest minimatch@latest graceful-fs@latest -g
npm install --global gulp eslint

yum install -y \
  java-11-openjdk-devel \
  git \
  yarn-1.21.1-1 \
  azure-cli-2.0.77 \
  docker-ce \
  make \
  gcc-c++ \
  google-chrome-stable \
  mesa-libOSMesa \
  mesa-libOSMesa-devel \
  gnu-free-sans-fonts \
  ipa-gothic-fonts \
  ipa-pgothic-fonts \
  libXcursor \
  libXdamage \
  libXScrnSaver \
  libXrandr \
  pango \
  atk \
  at-spi2-atk \
  gtk3 \
  wget

LIBOSMESA=$(find / -name 'libOSMesa*' -type f)
ln -s $LIBOSMESA /opt/google/chrome/libosmesa.so
echo 'user.max_user_namespaces=10000' > /etc/sysctl.d/90-userspace.conf
grubby --args=namespace.unpriv_enable=1 --update-kernel=$(grubby --default-kernel)

yum install -y rh-ruby24 rh-ruby24-ruby-devel

mkdir /etc/docker && chown -R root:root /etc/docker && chmod 0755 /etc/docker
echo -e '{\n  \live-restore\: true,\n  \group\: \docker\\n}' > /etc/docker/daemon.json && chown root:root /etc/docker/daemon.json && chmod 0644 /etc/docker/daemon.json
systemctl enable docker

cp /etc/chrony.conf{,.orig}
echo \refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0\ > /etc/chrony.conf && cat /etc/chrony.conf

rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
yum --releasever=7 update && yum install -y libunwind libicu dotnet-runtime-2.1.0-rc1

wget -O /tmp/azcopy.tar.gz https://aka.ms/downloadazcopylinux64
tar -xf /tmp/azcopy.tar.gz -C /tmp
/tmp/install.sh
rm -rf /tmp/azcopy.tar.gz /tmp/azcopy /tmp/install.sh

mkdir /opt/nvm && chown 1001:1001 /opt/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | NVM_DIR=/opt/nvm bash

git clone -b v2.0.0-alpha3 https://github.com/tfutils/tfenv.git /opt/tfenv
ln -s /opt/tfenv/bin/* /bin

yum install -y unzip

tfenv install 0.13.5 && chown -R 1001:1001 /opt/tfenv

rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
yum -y install dotnet-sdk-5.0
