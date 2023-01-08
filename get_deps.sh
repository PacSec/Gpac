#!/usr/bin/env bash

def_path="$(pwd)"


if [ -d "./tmp" ]; then
clear
echo "Start build!"
else
clear
echo "Start build!"
mkdir ./tmp
fi

if [ ! -d "./tmp/profile" ]; then
sudo cp -r ./profile ./tmp/profile
else
sudo rm -rf ./tmp/profile
sudo cp -r ./profile ./tmp/profile
fi

sudo chown -R $USER ./tmp

case_depz() {
        echo "[Pacman install deps...]"
    ###############   Dep's Install   #################
        sudo pacman --needed -Sy gcc re2 aria2 go protobuf git arch-install-scripts bash dosfstools e2fsprogs erofs-utils grub libarchive libisoburn make mtools squashfs-tools syslinux libnetfilter_queue libpcap python-grpcio python-protobuf python-slugify python-pyqt5 abseil-cpp python-pyinotify python-notify2 go python-grpcio-tools python-setuptools python-nspektr python-jaraco.text qt5-tools logrotate hicolor-icon-theme python-pip golang-github-google-go-cmp --noconfirm
        }
case_depz




case_opensnitch() {


        if [ ! -d $def_path/tmp/aur ]; then

                mkdir $def_path/tmp/aur

        fi

        if [ -d $def_path/tmp/opensnitch-git ]; then

                        echo "[OpenSnitch] -> [!Src Exist!]"

                        pip install qt-material pyasn
                        sudo cp $def_path/tmp/opensnitch-git/opensnitch-git*.zst $def_path/tmp/aur/

                        if [ ! -d $def_path/tmp/profile/airootfs/usr/lib/python3.10/site-packages ]; then

                                mkdir -p $def_path/tmp/profile/airootfs/usr/lib/python3.10/site-packages

                        fi

                        sudo cp -r /usr/lib/python3.10/site-packages/pyasn* $def_path/tmp/profile/airootfs/usr/lib/python3.10/site-packages/
                        sudo cp -r /usr/lib/python3.10/site-packages/qt_material* $def_path/tmp/profile/airootfs/usr/lib/python3.10/site-packages/

                        echo "[OpenSnitch] -> [!OK!]"

        else

                        echo "[OpenSnitch] -> [Build...]"

                        script() {

                                pip install qt-material pyasn
                                git clone https://aur.archlinux.org/opensnitch-git.git $def_path/tmp/opensnitch-git
                                cd $def_path/tmp/opensnitch-git
                                makepkg --noconfirm -sf
                                sudo cp $def_path/tmp/opensnitch-git/opensnitch-git*.zst $def_path/tmp/aur/

                                if [ ! -d $def_path/tmp/profile/airootfs/usr/lib/python3.10/site-packages ]; then

                                        mkdir -p $def_path/tmp/profile/airootfs/usr/lib/python3.10/site-packages

                                fi

                                sudo cp -r /usr/lib/python3.10/site-packages/pyasn* $def_path/tmp/profile/airootfs/usr/lib/python3.10/site-packages/
                                sudo cp -r /usr/lib/python3.10/site-packages/qt_material* $def_path/tmp/profile/airootfs/usr/lib/python3.10/site-packages/

                                echo "[OpenSnitch] -> [!OK!]"

                                cd $def_path
                        }; script

        fi
        cd $def_path

}

case_opensnitch




case_libhardened_malloc() {

        if [ -d $def_path/tmp/hardened_malloc ]; then
                echo "[Hardened_Malloc] -> [!Src Exist!]"
                sudo cp $def_path/tmp/hardened_malloc/out/libhardened_malloc.so $def_path/tmp/profile/airootfs/usr/lib/libhardened_malloc.so
        else
                echo "[Hardened_Malloc] -> [Build...]"

                script() {
                        git clone https://github.com/GrapheneOS/hardened_malloc/ $def_path/tmp/hardened_malloc
                        cd $def_path/tmp/hardened_malloc
                        make
                        sudo cp ./out/libhardened_malloc.so $def_path/tmp/profile/airootfs/usr/lib/libhardened_malloc.so
                }; script
        fi
        cd $def_path
}

if [ -f "$def_path/tmp/profile/airootfs/usr/lib/libhardened_malloc.so" ]; then
        echo "[Hardened_Malloc] -> [!OK!]"
        sleep 1
else
        case_libhardened_malloc
        sleep 1
fi





sudo chown -R live $def_path/tmp/profile

### FOR AUR PKG LOCAL REPO
sudo chown -R live $def_path/tmp/aur
cd $def_path/tmp/aur
repo-add -n -R Gpac_repo.db.tar.zst *.pkg.tar.zst
rm Gpac_repo.{db,files}
cp -f Gpac_repo.db.tar.zst Gpac_repo.db
cp -f Gpac_repo.files.tar.zst Gpac_repo.files

bash -c "echo -e '[Gpac_repo]
SigLevel = Optional TrustAll
Server = file://$def_path/tmp/aur' >> $def_path/tmp/profile/pacman.conf" 1> /dev/null

echo "Done repo-add pkg"
