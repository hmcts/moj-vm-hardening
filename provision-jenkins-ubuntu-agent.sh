#! /bin/bash -xe
echo '-----BEGIN RSA PRIVATE KEY-----' | tee /opt/jenkinsssh_id_rsa
echo $JENKINS_SSH_KEY | sed -e 's/[[:blank:]]\\+/\\n/g' | tee -a /opt/jenkinsssh_id_rsa
echo '-----END RSA PRIVATE KEY-----' | tee -a /opt/jenkinsssh_id_rsa

apt update -y
apt install -y python3-pip
apt install -y python3-testresources
apt install -y python2
pip3 install --upgrade setuptools
pip3 install --upgrade pip
pip3 install --upgrade docker-compose
pip3 install --upgrade virtualenv

curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
apt install -y nodejs

npm install npm@latest minimatch@latest graceful-fs@latest -g
npm install --global gulp eslint

npm install --global yarn

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt remove docker docker-engine docker.io containerd runc -y && apt autoremove -y
apt-get update
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Playwright dependencies. Generated with: npx playwright install-deps
apt-get install -y --no-install-recommends gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good libatk-bridge2.0-0 libatk1.0-0 libcairo2 libegl1 libenchant1c2a libepoxy0 libevdev2 \
  libfontconfig1 libfreetype6 libgdk-pixbuf2.0-0 libgl1 libgles2 libglib2.0-0 libgstreamer-gl1.0-0 libgstreamer1.0-0 \
  libgtk-3-0 libharfbuzz-icu0 libharfbuzz0b libhyphen0 libicu66 libjpeg-turbo8 libnotify4 libopenjp2-7 libopus0 \
  libpango-1.0-0 libpng16-16 libsecret-1-0 libsoup2.4-1 libvpx6 libwayland-client0 libwayland-egl1 libwayland-server0 \
  libwebp6 libwebpdemux2 libwoff1 libx11-6 libxcomposite1 libxdamage1 libxkbcommon0 libxml2 libxslt1.1 ffmpeg \
  libcairo-gobject2 libdbus-1-3 libdbus-glib-1-2 libpangocairo-1.0-0 libpangoft2-1.0-0 libx11-xcb1 libxcb-shm0 \
  libxcb1 libxcursor1 libxext6 libxfixes3 libxi6 libxrender1 libxt6 xvfb fonts-noto-color-emoji ttf-unifont \
  libfontconfig xfonts-cyrillic xfonts-scalable fonts-liberation fonts-ipafont-gothic fonts-wqy-zenhei \
  fonts-tlwg-loma-otf ttf-ubuntu-font-family

apt install -y \
  ca-certificates \
  curl \
  gnupg \
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
  wget

update-alternatives  --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java

#### RVM

gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --ruby

# install common ruby versions to make CI faster
rvm install 2.7.6

####

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install -y ./google-chrome-stable_current_amd64.deb

TFCMT_VERSION=v3.2.1
curl -fL -o tfcmt.tar.gz https://github.com/suzuki-shunsuke/tfcmt/releases/download/$TFCMT_VERSION/tfcmt_linux_amd64.tar.gz
tar -C /usr/bin -xzf ./tfcmt.tar.gz tfcmt

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/postgresql-pgdg.list > /dev/null
apt update
apt install -y postgresql postgresql-contrib

wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt update
apt install -y apt-transport-https dotnet-sdk-5.0 apt-transport-https aspnetcore-runtime-5.0

[ -e /opt/google/chrome/libosmesa.so ] && rm /opt/google/chrome/libosmesa.so
LIBOSMESA=$(find / -name 'libOSMesa*' -type f)
ln -s $LIBOSMESA /opt/google/chrome/libosmesa.so
echo 'user.max_user_namespaces=10000' > /etc/sysctl.d/90-userspace.conf
# grubby --args=namespace.unpriv_enable=1 --update-kernel=$(grubby --default-kernel)

apt install -y ruby-full ruby-dev chrony

mkdir /etc/docker && chown -R root:root /etc/docker && chmod 0755 /etc/docker
echo -e '{\n  \live-restore\: true,\n  \group\: \docker\\n}' > /etc/docker/daemon.conf && chown root:root /etc/docker/daemon.conf && chmod 0644 /etc/docker/daemon.conf
systemctl enable docker

cp /etc/chrony/chrony.conf{,.orig}
echo \refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0\ > /etc/chrony/chrony.conf && cat /etc/chrony/chrony.conf

#Download AzCopy
wget https://aka.ms/downloadazcopy-v10-linux

#Expand Archive
tar -xvf downloadazcopy-v10-linux

#Move AzCopy to the destination you want to store it
cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

mkdir /opt/nvm && chown 1001:1001 /opt/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | NVM_DIR=/opt/nvm bash

git clone -b v2.0.0-alpha3 https://github.com/tfutils/tfenv.git /opt/tfenv
ln -s /opt/tfenv/bin/* /bin

apt install -y unzip

tfenv install 0.13.5 && chown -R 1001:1001 /opt/tfenv

packages=( az azcopy cloud-init docker docker-compose dotnet eslint gcc git google-chrome gulp java /usr/lib/jvm/java-17-openjdk-amd64/bin/java make node npm psql rsync terraform tfcmt tfenv virtualenv yarn wget )

for i in "${packages[@]}"

do
  if command -v "${i}"; then
     echo -n "${i} is installed. Version is "; ${i} --version
  else
     echo "${i} is missing!"
     exit 1
  fi
done


