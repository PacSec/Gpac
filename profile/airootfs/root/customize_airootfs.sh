 #!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist


# Enable service when available
{ [[ -e /usr/lib/systemd/system/acpid.service                ]] && systemctl enable acpid.service;
  [[ -e /usr/lib/systemd/system/NetworkManager.service       ]] && systemctl enable NetworkManager.service;
} > /dev/null 2>&1

# Set sddm display-manager
ln -s /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service

# Add live user
# * groups member
# * user without password
# * sudo no password settings
useradd -m -G 'wheel' -s /bin/zsh live
usermod -a -G 'libvirt' live
sed -i 's/^\(live:\)!:/\1:/' /etc/shadow
sed -i 's/^#\s\(%wheel\s.*NOPASSWD\)/\1/' /etc/sudoers



bash -c 'echo "[Unit]
    Description=My Service
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/usbkill
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target" > /lib/systemd/system/usbkill.service' 1> /dev/null

bash -c 'echo "{
    "Server": {
        "Address": "unix:///tmp/osui.sock",
        "LogFile": "/var/log/opensnitchd.log"
    },
    "DefaultAction": "deny",
    "DefaultDuration": "once",
    "InterceptUnknown": false,
    "ProcMonitorMethod": "proc",
    "LogLevel": 2,
    "Firewall": "nftables",
    "Stats": {
        "MaxEvents": 150,
        "MaxStats": 25,
        "Workers": 6
    }
}" > /etc/opensnitchd/default-config.json' 1> /dev/null
chmod 644 /etc/opensnitchd/default-config.json

systemctl enable usbkill.service
systemctl enable opensnitchd.service
systemctl enable libvirtd.service

# disable systemd-networkd.service
# we have NetworkManager for managing network interfaces
[[ -e /etc/systemd/system/multi-user.target.wants/systemd-networkd.service ]] && rm /etc/systemd/system/multi-user.target.wants/systemd-networkd.service
[[ -e /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service ]] && rm /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service
[[ -e /etc/systemd/system/sockets.target.wants/systemd-networkd.socket ]] && rm /etc/systemd/system/sockets.target.wants/systemd-networkd.socket
[[ -e /etc/systemd/system/libvirtd.service ]] && rm /etc/systemd/system/libvirtd.service
[[ -e /etc/systemd/system/macspoof.service ]] && rm /etc/systemd/system/macspoof.service
[[ -e /etc/systemd/system/systemd-resolved.service ]] && rm /etc/systemd/system/systemd-resolved.service



echo "/usr/lib/libhardened_malloc.so" > /etc/ld.so.preload
echo "vm.max_map_count = 1048576" > /etc/sysctl.d/hardened_malloc.conf

echo "-----------------------"
echo "ROOT SCRIPT COMPLETE!!!"
echo "ROOT SCRIPT COMPLETE!!!"
echo "ROOT SCRIPT COMPLETE!!!"
echo "-----------------------"


