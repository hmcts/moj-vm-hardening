#!/bin/bash

## all versions of utilities are set here
## the renovate comments enable renovatebot to update these dynamically via GitHub pull requests

#renovate: datasource=github-tags depName=fluxcd/flux2
export FLUX_VERSION=$(echo v2.0.1 | tr -d 'v')
#renovate: datasource=github-tags depName=helm/helm
export HELM_VERSION=$(echo v3.12.2 | tr -d 'v')
#renovate: datasource=github-tags depName=kubernetes/kubectl
export KUBECTL_VERSION=$(echo v1.26.0 | tr -d 'v')
#renovate: datasource=node-version depName=node versioning=node
export NODE_VERSION=$(echo 14 | tr -d 'v')
#renovate: datasource=github-tags depName=nvm-sh/nvm
export NVM_VERSION=$(echo v0.39.3 | tr -d 'v')
#renovate: datasource=ruby-version depName=ruby
export RUBY_VERSION=$(echo 2.7.8 | tr -d 'v')
#renovate: datasource=github-tags depName=SonarSource/sonar-scanner-cli versioning=regex
export SONAR_SCANNER_VERSION=$(echo 4.7.0.2747 | tr -d 'v')
#renovate: datasource=github-tags depName=hashicorp/terraform
export TF_VERSION=$(echo v0.15.5 | tr -d 'v')
#renovate: datasource=github-tags depName=suzuki-shunsuke/tfcmt
export TFCMT_VERSION=$(echo v3.4.2 | tr -d 'v')
#renovate: datasource=github-tags depName=tfutils/tfenv
export TFENV_VERSION=$(echo v2.2.3 | tr -d 'v')

set -xe

echo '-----BEGIN RSA PRIVATE KEY-----' | tee /opt/jenkinsssh_id_rsa
echo $JENKINS_SSH_KEY | sed -e 's/[[:blank:]]\\+/\\n/g' | tee -a /opt/jenkinsssh_id_rsa
echo '-----END RSA PRIVATE KEY-----' | tee -a /opt/jenkinsssh_id_rsa

remove_packages=( docker docker-engine docker.io runc )

for i in "${remove_packages[@]}"

do
    installed=$(which ${i} > /dev/null &&  echo 0 || echo 1)
    if [ $installed = 0 ]; then
      apt remove ${i} -y
    fi
done

apt autoremove -y

apt update

apt install -y \
  ca-certificates \
  curl \
  gnupg \
  gnupg2 \
  lsb-release

## debugging why python3-pip sometime can't be found
cat /etc/apt/sources.list
apt-cache policy python3-pip
## end debug

echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

apt purge nodejs -y
rm -rf /etc/apt/sources.list.d/nodesource.list

curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash

apt update
apt install -y nodejs

install -m 0755 -d /etc/apt/keyrings
rm -rf /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Required to avoid being prompted to restart services while installing pyenv pre-requisites
export NEEDRESTART_SUSPEND=1
export DEBIAN_FRONTEND=noninteractive

apt update

# Playwright dependencies. Generated with: npx playwright install-deps
apt install -y --no-install-recommends gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good libatk-bridge2.0-0 libatk1.0-0 libcairo2 libegl1 libenchant-2-dev libepoxy0 libevdev2 \
  libfontconfig1 libfreetype6 libgdk-pixbuf2.0-0 libgl1 libgles2 libglib2.0-0 libgstreamer-gl1.0-0 libgstreamer1.0-0 \
  libgtk-3-0 libharfbuzz-icu0 libharfbuzz0b libhyphen0 libjpeg-turbo8 libnotify4 libopenjp2-7 libopus0 \
  libpango-1.0-0 libpng16-16 libsecret-1-0 libsoup2.4-1 libwayland-client0 libwayland-egl1 libwayland-server0 \
  libwebpdemux2 libwoff1 libx11-6 libxcomposite1 libxdamage1 libxkbcommon0 libxml2 libxslt1.1 ffmpeg \
  libcairo-gobject2 libdbus-1-3 libdbus-glib-1-2 libpangocairo-1.0-0 libpangoft2-1.0-0 libx11-xcb1 libxcb-shm0 \
  libxcb1 libxcursor1 libxext6 libxfixes3 libxi6 libxrender1 libxt6 xvfb fonts-noto-color-emoji ttf-unifont \
  libfontconfig xfonts-cyrillic xfonts-scalable fonts-liberation fonts-ipafont-gothic fonts-wqy-zenhei \
  fonts-tlwg-loma-otf

sleep 10

apt update

apt install -y \
  python3-pip \
  python3-testresources \
  python2 \
  lsb-release \
  openjdk-11-jdk \
  openjdk-17-jdk \
  git \
  azure-cli \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  make \
  build-essential \
  libosmesa6 \
  libosmesa6-dev \
  libxcursor1 \
  libxdamage1 \
  libxrandr2 \
  libpango-1.0-0 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libgtk-3-0 \
  libxss1 \
  rsync \
  libpq-dev \
  postgresql \
  postgresql-contrib \
  apt-transport-https \
  apt-transport-https \
  zip \
  unzip \
  wget \
  jq \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  llvm \
  libncursesw5-dev \
  xz-utils \
  tk-dev \
  libxml2-dev \
  libxmlsec1-dev \
  libffi-dev \
  liblzma-dev \
  gettext \
  libncurses-dev

wget https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz -O - | tar xz
mv flux /usr/local/bin/flux

wget https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl

wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar xz
mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64
chmod +x /usr/local/bin/kubectl

pip3 install --upgrade docker-compose pip pip-check pyopenssl setuptools virtualenv

USER=$(whoami)

PATH=$PATH:/home/$USER/.local/bin

npm install npm@latest minimatch@latest graceful-fs@latest -g
npm install --global \
  gulp \
  eslint \
  yarn

update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java

#### RVM

# uses non default server due to firewall blocking the default
# https://serverfault.com/a/1088077/385948
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --ruby

source /usr/local/rvm/scripts/rvm
# install common ruby versions to make CI faster
rvm install ${RUBY_VERSION}

####

curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome-stable_current_amd64.deb
apt install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

curl -fL -o tfcmt.tar.gz https://github.com/suzuki-shunsuke/tfcmt/releases/download/v${TFCMT_VERSION}/tfcmt_linux_amd64.tar.gz
tar -C /usr/bin -xzf ./tfcmt.tar.gz tfcmt

[ -e /opt/google/chrome/libosmesa.so ] && rm /opt/google/chrome/libosmesa.so
LIBOSMESA=$(find /usr -name 'libOSMesa*' -type f)
ln -s $LIBOSMESA /opt/google/chrome/libosmesa.so
echo 'user.max_user_namespaces=10000' > /etc/sysctl.d/90-userspace.conf
# grubby --args=namespace.unpriv_enable=1 --update-kernel=$(grubby --default-kernel)

mkdir /etc/docker && chown -R root:root /etc/docker && chmod 0755 /etc/docker
echo -e '{\n  \live-restore\: true,\n  \group\: \docker\\n}' > /etc/docker/daemon.conf && chown root:root /etc/docker/daemon.conf && chmod 0644 /etc/docker/daemon.conf
systemctl enable docker

# this doesn't exist in a container, flagged so this works when we test the script
FILE=/etc/chrony/chrony.conf
if test -f "$FILE"; then
  cp /etc/chrony/chrony.conf{,.orig}
  echo \refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0\ > /etc/chrony/chrony.conf && cat /etc/chrony/chrony.conf
fi

#Download AzCopy
wget https://aka.ms/downloadazcopy-v10-linux

#Expand Archive
tar -xvf downloadazcopy-v10-linux

#Move AzCopy to the destination you want to store it
cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

# see https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip \
  -O /opt/sonar-scanner-cli.zip
unzip -o /opt/sonar-scanner-cli.zip -d /opt

rm -rf /bin/sonar-scanner
ln -s /opt/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner /bin/sonar-scanner

rm -f /opt/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip

mkdir /opt/nvm && chown 1001:1001 /opt/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | NVM_DIR=/opt/nvm bash

rm -rf /opt/tfenv /bin/terraform /bin/tfenv
git clone -b v${TFENV_VERSION} https://github.com/tfutils/tfenv.git /opt/tfenv
ln -s /opt/tfenv/bin/* /bin

tfenv install ${TF_VERSION} && chown -R 1001:1001 /opt/tfenv

rm -rf /opt/.pyenv
rm -rf /bin/pyenv
export PYENV_ROOT=/opt/.pyenv
curl https://pyenv.run | bash
ln -s /opt/.pyenv/bin/* /bin
chown -R 1001:1001 /opt/.pyenv

packages=( az azcopy docker docker-compose eslint gcc git google-chrome gulp java /usr/lib/jvm/java-17-openjdk-amd64/bin/java jq make node npm psql pyenv ruby rsync sonar-scanner terraform tfcmt tfenv virtualenv yarn wget zip )

for i in "${packages[@]}"

do
    installed=$(which ${i} > /dev/null &&  echo 0 || echo 1)
    if [ $installed = 1 ]; then
        echo "${i} is missing. Please install ${i} before continuing"
        exit 1
    else
      echo "${i} is installed"
    fi
done

printf "Package installed via pip are listed below with their versions\n"
pip-check

printf "Packages installed via apt are listed below with their versions\n"
dpkg -l | grep "^ii"
