#!/bin/bash
#!/bin/bash

echo "Welcome to my archinstall script"
echo "This was mainly written for me to learn how the install process works. Please do not use this expecting it to work."
sleep 1
echo -n "Checking for internet..."
ping -c 3 google.com >/dev/null 2>&1
ipstatus=$?
if [[ $ipstatus -eq 2 ]]; then
  echo " Failed!"
  sleep .5
  echo "Error: No internet access. Please check your internet connection and try again"
  echo "Would you like to attempt to connect to wifi? [Y/N]"
  while [[ "$config" != "y" && "$config" != "n" ]]; do
    read -r -p "Invalid input. Please enter y or n: " confirm
  done
  if [ "$config" = y ]; then
    echo "Initializing network scan on interface 'wlan0'..."
    iwctl station wlan0 scan > /dev/null
    sleep 2
    echo "Scan complete. getting network list..."
    iwctl station wlan0 get-networks
    read -r -p "Enter the SSID of the network you would like to connect to: " ssid
    echo "Requesting security method for network $ssid"
    iwctl station wlan0 connect $ssid
    echo "Attempting connection..."
    sleep 2
    echo "Testing connection..."
    ping -c 3 google.com >/dev/null 2>&1
    ipstatus=$?
    if [[ $ipstatus -eq 0 ]]; then
      echo "Connection verified. Launching installer..."
      sleep 1
      clear
    else
      echo "Connection attempt failed"
      exit 1
    fi
  else
    echo "You need internet access to proceed with the installation process."
    echo "Please get internet access and try again"
    exit 1
  fi
else
  echo " Done!"
  echo "Connection verified. Launching installer..."
  sleep 1
  clear
fi

# Parse archinstall.conf
echo "Would you like to import an existing config file? [Y/N]"
read -r config
while [[ "$config" != "y" && "$config" != "n" ]]; do
  read -r -p "Invalid input. Please enter y or n: " confirm
done
if [ "$config" = y ]; then
  echo "Please enter the path to your config file (eg /etc/archinstall.conf)"
  read -r configpath
  echo "Parsing config file..."
  config_file=$configpath
  declare -A config

  while IFS=": " read -r key value; do
    config["$key"]="$value"
  done <"$config_file"
  diskmode="${config["Disk configuration"]}"
  echo "Parsing disk configuration: $diskmode"
  sleep .2
  rootpwd="${config["Root password"]}"
  echo "Parsing root password: $rootpwd"
  sleep .2
  uname="${config["Username"]}"
  echo "Parsing username: $uname"
  sleep .2
  upwd="${config["User password"]}"
  echo "Parsing user password: $diskmode"
  sleep .2
  sudoer="${config["Sudoer"]}"
  echo "Parsing $uname sudo access: $sudoer"
  sleep .2
  kernel="${config["Kernel"]}"
  echo "Parsing kernel configuration: $kernel"
  sleep .2
  de="${config["Desktop enviroment"]}"
  echo "Parsing disk configuration: $de"
  sleep .2
  packages="${config["Additional packages"]}"
  echo "Parsing additional packages: $packages"
  sleep .2
  yay="${config["Yay installation"]}"
  echo "Parsing aur helper: $yay"
  sleep .2
  echo -n "Finishing up..."
  sleep 1
  echo " Done"
  sleep 1
  echo "Please review the following installation settings:"
  if [ "$diskmode" = "p" ]; then
    echo "Disk configuration: Pre-mounted (/mnt)"
  else
    echo "Disk configuration: Other"
  fi
  echo "Root password: $rootpwd"
  echo "Username: $uname"
  echo "User password: $upwd"
  if [ "$sudoer" = "y" ]; then
    echo "Sudoer: Yes"
  else
    echo "Sudoer: No"
  fi
  if [ "$kernel" = "y" ]; then
    echo "Kernel: Custom"
  else
    echo "Kernel: Default"
  fi
  echo "Desktop enviroment: $de"
  echo "Additional packages: $packages"
  if [ "$yay" = y ]; then
    echo "Yay installation: Yes"
  elif [ "$yay" = n ]; then
    echo "Yay installation: No"
  else
    echo "Yay installation: Undefined"
  fi
  echo "Would you like to begin the installation?"
  read -r install
  while [[ "$install" != "y" && "$install" != "n" ]]; do
    read -r -p "Invalid input. Please enter Y or N: " install
  done
  if [[ "$install" == "y" ]]; then
    echo "Beginning installation..."
    sleep 1
    echo "Installing base system..."
    pacstrap /mnt base linux linux-firmware
    echo "Finished"
    echo "Generating fstab..."
    genfstab -U /mnt >>/mnt/etc/fstab
    echo "Fstab generated"
    echo "Chrooting into new system..."
    arch-chroot /mnt
    echo "Chroot complete"
    echo "Setting timezone..."
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    echo "Timezone set"
    echo "Setting hardware clock..."
    hwclock --systohc
    echo "Hardware clock set"
    echo "Setting locale..."
    echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" >/etc/locale.conf
    echo "Locale set"
    echo "Setting hostname..."
    echo "arch" >/etc/hostname
    echo "Hostname set"
    echo "Installing essential packages..."
    pacman -S --noconfirm networkmanager grub efibootmgr git "$packages"
    echo "Finished"
    echo "Installing desktop enviroment..."
    if [ "$de" == "GNOME" ]; then
      pacman -S --noconfirm gnome gnome-tweaks
      dm="gdm"
    elif [ "$de" == "KDE Plasma" ]; then
      pacman -S --noconfirm plasma-desktop sddm
      dm="sddm"
    else
      echo "Invalid desktop enviroment. Please install manually"
    fi

    echo "Finished"
    echo "Enabling startup services..."
    systemctl enable NetworkManager $dm
    echo "Finished"
    echo "Setting root password..."
    echo "$rootpwd" | chpasswd
    echo "Root password set"
    echo "Creating user..."
    if [ $sudoer = "y" ]; then
      useradd -m -G wheel $uname
      echo "$upwd" | chpasswd
      echo "Modifying /etc/sudoers..."
      sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
      echo "Wheel grouo added to sudoers"
    else
      useradd -m $uname
      echo "$upwd" | chpasswd
    fi
    echo "User $uname created"
    echo "Installing Yay..."
    git clone
  fi
  clear
  echo "Installaton finished with no errors."
  echo "IMPORTANT: Please remember to install a bootloader before rebooting"
  exit 0
else
  echo "Proceeding with installation"
fi
echo "Would you like to generate a new mirrorlist?"
echo "[Y]es [N]o"
read -r confirm
while [[ "$confirm" != "y" && "$confirm" != "n" ]]; do
  read -r -p "Invalid input. Please enter y or n: " confirm
done

if [[ "$confirm" == "y" ]]; then
  echo -n "Generating country list..."
  countrylist="$(reflector --list-countries 2>&1)"
  echo " Done!"
  sleep 1
  echo "$countrylist"
  echo "Mirrorlist setting coming soon. Please run 'reflector' to generate a custom mirrorlist"
else
  echo "Proceeding without a custom mirrorlist"
fi
sleep 1
echo "2: Disk configuration"
sleep .5
echo "Please select an option"
echo "[P]re-mounted config [O]ther (Coming soon)"
read -r diskmode
while [[ "$diskmode" != "p" && "$diskmode" != "o" ]]; do
  read -r -p "Invalid input. Please enter one of the prefixes shown above: " diskmode
done

if [[ "$diskmode" == "p" ]]; then
  echo "This assumes all of your necessary partitions are mounted at /mnt."
  echo "Proceeding..."
fi

sleep 1
echo "3. Users and passwords"
echo "Please enter a password to use for the root account. Leaving blank will disable root (not recommended)"
read -r -s -p "Password: " rootpwd
echo "A user will now be created. Please enter a username for this user"
read -r -p "Username: " uname
echo "Please enter a password for this user"
read -r -s -p "Password: " upwd
echo "Should user $uname be a sudoer?"
read -r sudoer
while [[ "$sudoer" != "y" && "$sudoer" != "n" ]]; do
  read -r -p "Invalid input. Please enter Y or N: " sudoer
done
echo "4. Installation customization"
echo "Would you like to install a different kernel? (Coming soon)"
read -r kernel
while [[ "$kernel" != "y" && "$kernel" != "n" ]]; do
  read -r -p "Invalid input. Please enter Y or N: " kernel
done
echo "Please enter a desktop enviroment to install ([g]nome, [k]de, *more coming soon*)"
read -r de
if [[ "$de" == "g" ]]; then
  echo "GNOME will be installed"
  de=("GNOME")
elif [[ "$de" == "k" ]]; then
  echo "KDE Plasma will be installed"
  de=("KDE Plasma")
else
  echo "Invalid input. Please enter one of the prefixes shown above"
fi
sleep 1
echo "Enter any additional packages you would like to install, separated by spaces"
read -r packages
sleep 1
echo "Would you like to install yay?"
read -r yay
echo -n "Finishing up configuration..."
echo " Done!"
clear
echo "Please review the following installation settings:"
if [ "$diskmode" = "p" ]; then
  echo "Disk configuration: Pre-mounted (/mnt)"
else
  echo "Disk configuration: Other"
fi
echo "Root password: $rootpwd"
echo "Username: $uname"
echo "User password: $upwd"
if [ "$sudoer" = "y" ]; then
  echo "Sudoer: Yes"
else
  echo "Sudoer: No"
fi
if [ "$kernel" = "y" ]; then
  echo "Kernel: Custom"
else
  echo "Kernel: Default"
fi
echo "Desktop enviroment: $de"
echo "Additional packages: $packages"
if [ "$yay" = y ]; then
  echo "Yay installation: Yes"
elif [ "$yay" = n ]; then
  echo "Yay installation: No"
else
  echo "Yay installation: Undefined"
fi
echo "Would you like to save these settings to a file?"
read -r save
while [[ "$save" != "y" && "$save" != "n" ]]; do
  read -r -p "Invalid input. Please enter Y or N: " save
done
if [[ "$save" == "y" ]]; then
  echo "Saving settings to file..."
  echo "Writing disk configuration to archinstall.conf..."
  echo "Disk configuration: $diskmode" >archinstall.conf
  sleep .1
  echo "Writing root password to archinstall.conf..."
  echo "Root password: $rootpwd" >>archinstall.conf
  sleep .1
  echo "Writing username to archinstall.conf..."
  echo "Username: $uname" >>archinstall.conf
  sleep .1
  echo "Writing user password to archinstall.conf..."
  echo "User password: $upwd" >>archinstall.conf
  echo "Sudoer: $sudoer" >>archinstall.conf
  sleep .1
  echo "Writing kernel configuration to archinstall.conf..."
  echo "Kernel: $kernel" >>archinstall.conf
  sleep .1
  echo "Writing desktop enviroment to archinstall.conf..."
  echo "Desktop enviroment: $de" >>archinstall.conf
  sleep .1
  echo "Writing additional packages and AUR helper to archinstall.conf..."
  echo "Additional packages: $packages" >>archinstall.conf
  echo "Yay installation: $yay" >>archinstall.conf
  sleep 1
  echo "Settings saved to archinstall.conf"
else
  echo "Proceeding without saving settings"
fi
echo "Would you like to begin the installation?"
read -r install
while [[ "$install" != "y" && "$install" != "n" ]]; do
  read -r -p "Invalid input. Please enter Y or N: " install
done
if [[ "$install" == "y" ]]; then
  echo "Beginning installation..."
  sleep 1
  echo "Installing base system..."
  pacstrap /mnt base linux linux-firmware
  echo "Finished"
  echo "Generating fstab..."
  genfstab -U /mnt >>/mnt/etc/fstab
  echo "Fstab generated"
  echo "Chrooting into new system..."
  arch-chroot /mnt
  echo "Chroot complete"
  echo "Setting timezone..."
  ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
  echo "Timezone set"
  echo "Setting hardware clock..."
  hwclock --systohc
  echo "Hardware clock set"
  echo "Setting locale..."
  echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" >/etc/locale.conf
  echo "Locale set"
  echo "Setting hostname..."
  echo "arch" >/etc/hostname
  echo "Hostname set"
  echo "Installing essential packages..."
  pacman -S --noconfirm networkmanager grub efibootmgr git "$packages"
  echo "Finished"
  echo "Installing desktop enviroment..."
  if [ "$de" == "GNOME" ]; then
    pacman -S --noconfirm gnome gnome-tweaks
    dm="gdm"
  elif [ "$de" == "KDE Plasma" ]; then
    pacman -S --noconfirm plasma-desktop sddm
    dm="sddm"
  else
    echo "Invalid desktop enviroment. Please install manually"
  fi

  echo "Finished"
  echo "Enabling startup services..."
  systemctl enable NetworkManager $dm
  echo "Finished"
  echo "Setting root password..."
  echo "$rootpwd" | chpasswd
  echo "Root password set"
  echo "Creating user..."
  if [ $sudoer = "y" ]; then
    useradd -m -G wheel $uname
    echo "$upwd" | chpasswd
    echo "Modifying /etc/sudoers..."
    sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
    echo "Wheel grouo added to sudoers"
  else
    useradd -m $uname
    echo "$upwd" | chpasswd
  fi
  echo "User $uname created"
  echo "Installing Yay..."
  git clone
fi
clear
echo "Installaton finished with no errors."
echo "IMPORTANT: Please remember to install a bootloader before rebooting"
exit 0
