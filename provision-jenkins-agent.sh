#!/bin/bash -xe
echo '-----BEGIN RSA PRIVATE KEY-----' | tee /opt/jenkinsssh_id_rsa
echo $JENKINS_SSH_KEY | sed -e 's/[[:blank:]]\\+/\\n/g' | tee -a /opt/jenkinsssh_id_rsa
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
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
yum localinstall -y google-chrome-stable_current_x86_64.rpm

yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum-config-manager --enable pgdg11
yum install -y nodejs postgresql11

npm install npm@latest minimatch@latest graceful-fs@latest -g
npm install --global gulp eslint

npm install --global yarn

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo

yum install -y \
  java-11-openjdk-devel \
  git \
  azure-cli \
  docker-ce \
  make \
  gcc-c++ \
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


curl https://packages.microsoft.com/config/rhel/7/prod.repo > ./microsoft-prod.repo
sudo cp ./microsoft-prod.repo /etc/yum.repos.d/
yum update -y
yum --releasever=7 update && yum install -y libunwind libicu dotnet-sdk-5.0

LIBOSMESA=$(find / -name 'libOSMesa*' -type f)
ln -s $LIBOSMESA /opt/google/chrome/libosmesa.so
echo 'user.max_user_namespaces=10000' > /etc/sysctl.d/90-userspace.conf
grubby --args=namespace.unpriv_enable=1 --update-kernel=$(grubby --default-kernel)

yum install -y rh-ruby24 rh-ruby24-ruby-devel

mkdir /etc/docker && chown -R root:root /etc/docker && chmod 0755 /etc/docker
echo -e '{\n  \live-restore\: true,\n  \group\: \docker\\n}' > /etc/docker/daemon.conf && chown root:root /etc/docker/daemon.conf && chmod 0644 /etc/docker/daemon.conf
systemctl enable docker

cp /etc/chrony.conf{,.orig}
echo \refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0\ > /etc/chrony.conf && cat /etc/chrony.conf

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

packages=(az azcopy docker dotnet npm psql pip3 terraform yarn)

for i in "${packages[@]}"

do
  	if command -v "${i}"; then
                echo -n "${i} is installed. Version is "; ${i} --version
        else
            	echo "${i} is missing!"
        fi
done