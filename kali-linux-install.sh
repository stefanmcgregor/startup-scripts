# Kali-linux-default non-interactive install script for Debian
# Tested on Debian 9
# Change Kali and VNC password variables below

kalipass='defaultkalipassword123'
vncpass='defaultkalipassword123'

# Set Locales
locale-gen en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales --default-priority

# Ensure dependency
apt-get -y install dirmngr

# Add Kali repo key to apt
apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys 7D8D0BF6

# Add Kali repos to source list
echo deb http://http.kali.org/kali kali-rolling main contrib non-free >> /etc/apt/sources.list
echo deb-src http://http.kali.org/kali kali-rolling main contrib non-free >> /etc/apt/sources.list

# Set Locales
locale-gen en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales --default-priority

# Set non-interactive
DEBIAN_FRONTEND=noninteractive

# Preset configurations (for kali-linux-full and xfce)
echo libc6/libraries libc6/libraries/restart-without-asking boolean true | debconf-set-selections
echo libc6 libraries/restart-without-asking boolean true | debconf-set-selections
echo libc6:amd64 libraries/restart-without-asking boolean true | debconf-set-selections
echo libpam0g:amd64 libraries/restart-without-asking boolean true | debconf-set-selections
echo samba-common samba-common/dhcp boolean false | debconf-set-selections
echo samba-common samba-common/do_debconf boolean true | debconf-set-selections
echo samba-common samba-common/workgroup string WORKGROUP | debconf-set-selections
echo macchanger macchanger/automatically_run boolean false | debconf-set-selections
echo wireshark-common wireshark-common/install-setuid boolean false | debconf-set-selections
echo kismet-capture-common kismet-capture-common/install-setuid boolean true | debconf-set-selections
echo kismet-capture-common kismet-capture-common/install-users string | debconf-set-selections
echo sslh sslh/inetd_or_standalone select standalone | debconf-set-selections
echo dictionaries-common dictionaries-common/selecting_ispell_wordlist_default note	| debconf-set-selections
echo ucf ucf/changeprompt_threeway select keep_current | debconf-set-selections


# Get latest information from the repos
apt-get -y update

# Install desktop environment
apt-get -y install kali-desktop-xfce 
apt-get -y update


# Install Kali meta-package
apt-get -y install kali-linux-default        # The Default Kali Linux Install (meant to save space)

# Upgrade old packages to the latest
apt-get -y update
apt-get -y upgrade

# Dist-upgrade 
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
apt-get -y autoremove

# Add Kali user with default password
useradd kali -m -p $kalipass
usermod -a -G sudo kali
chsh -s /bin/bash kali

# Install and setup X11VNC
apt-get install x11vnc -y

# Specify password to be used for VNC Connection 
x11vnc -storepasswd $vncpass /etc/x11vnc.pass

# Create the VNC service unit file
cat > /lib/systemd/system/x11vnc.service << EOF
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 65520 -shared

[Install]
WantedBy=multi-user.target
EOF
 
systemctl enable x11vnc.service
systemctl daemon-reload

#Update the databases
updatedb
mandb

# Sleep and shutdown
sleep  5s
sudo shutdown -r now 

