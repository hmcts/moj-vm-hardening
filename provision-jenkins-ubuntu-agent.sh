#! /bin/bash -xe
echo '-----BEGIN RSA PRIVATE KEY-----' | tee /opt/jenkinsssh_id_rsa
echo $JENKINS_SSH_KEY | sed -e 's/[[:blank:]]\\+/\\n/g' | tee -a /opt/jenkinsssh_id_rsa
echo '-----END RSA PRIVATE KEY-----' | tee -a /opt/jenkinsssh_id_rsa

bash --version

apt update -y
wget https://bootstrap.pypa.io/get-pip.py
sudo python3.6 get-pip.py
# sudo apt install -y python3-testresources
pip3 install --upgrade setuptools
pip3 install --upgrade pip
pip3 install --upgrade docker-compose

curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
apt install -y nodejs

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

npm install npm@latest minimatch@latest graceful-fs@latest -g
npm install --global gulp eslint

npm install --global yarn

sudo apt remove azure-cli -y && sudo apt autoremove -y
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  openjdk-11-jdk \
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
  wget

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql-pgdg.list > /dev/null
apt update
apt install -y postgresql postgresql-contrib

wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt update; \
  sudo apt install -y apt-transport-https && \
  sudo apt update && \
  sudo apt install -y dotnet-sdk-5.0
sudo apt update; \
  sudo apt install -y apt-transport-https && \
  sudo apt update && \
  sudo apt install -y aspnetcore-runtime-5.0 && \

[ -e /opt/google/chrome/libosmesa.so ] && rm /opt/google/chrome/libosmesa.so
LIBOSMESA=$(find / -name 'libOSMesa*' -type f)
ln -s $LIBOSMESA /opt/google/chrome/libosmesa.so
echo 'user.max_user_namespaces=10000' > /etc/sysctl.d/90-userspace.conf
# grubby --args=namespace.unpriv_enable=1 --update-kernel=$(grubby --default-kernel)

apt install -y ruby-full ruby-dev

mkdir /etc/docker && chown -R root:root /etc/docker && chmod 0755 /etc/docker
echo -e '{\n  \live-restore\: true,\n  \group\: \docker\\n}' > /etc/docker/daemon.conf && chown root:root /etc/docker/daemon.conf && chmod 0644 /etc/docker/daemon.conf
systemctl enable docker

cp /etc/chrony/chrony.conf{,.orig}
echo \refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0\ > /etc/chrony/chrony.conf && cat /etc/chrony/chrony.conf


#Download AzCopy
wget https://aka.ms/downloadazcopy-v10-linux

#Expand Archive
tar -xvf downloadazcopy-v10-linux

#(Optional) Remove existing AzCopy version
sudo rm /usr/bin/azcopy

#Move AzCopy to the destination you want to store it
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

mkdir /opt/nvm && chown 1001:1001 /opt/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | NVM_DIR=/opt/nvm bash

git clone -b v2.0.0-alpha3 https://github.com/tfutils/tfenv.git /opt/tfenv
ln -s /opt/tfenv/bin/* /bin

apt install -y unzip

tfenv install 0.13.5 && chown -R 1001:1001 /opt/tfenv

packages=( az azcopy cloud-init docker dotnet eslint gcc git google-chrome gulp java make node npm psql rsync terraform tfenv yarn wget )

for i in "${packages[@]}"

do
  if command -v "${i}"; then
     echo -n "${i} is installed. Version is "; ${i} --version
  else
     echo "${i} is missing!"
     exit 1
  fi
done