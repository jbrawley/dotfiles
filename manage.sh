#create ssh key and add to github
#ssh-keygen -t rsa

#install oh-my-zsh
#sudo apt-get install zsh
#chsh -s $(which zsh)
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#install google-chrome-stable
#addkey
#wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#set repository
#sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
#install package
# sudo apt-get update
# sudo apt-get install google-chrome-stable

#install postman
#wget -q --show-progress "https://dl.pstmn.io/download/latest/linux64" --content-disposition
#sudo tar -xzf Postman-linux-x64-5.0.2.tar.gz -C /opt
#rm Postman-linux-x64-5.0.2.tar.gz
#sudo ln -s /opt/Postman/Postman /usr/bin/postman

#!/usr/bin/env bash

# utility
#########

display_help() {
  cat <<-EOF
  A utiltiy for setting up configuration on any machine
  Usage: manage.sh <command>
  Commands:
  link-config              stow directories of this repo into ~
  install-packages         install base packages (from packages.txt)
  bootstrap                bootstrap my arch linux environment
EOF

  if [ $# -eq 0 ]; then
    exit 0
  fi

  exit $1
}

error(){
  printf "\033[31m%s\n\033[0m" "$@" >&2
  exit 1
}

# globals
#########

type greadlink >/dev/null 2>&1 && CWD="$(dirname "$(greadlink -f "$0")")" || \
  CWD="$(dirname "$(readlink -f "$0")")"

# functions
###########
link-config() {
  echo "Linking configuration..."
  for d in $(ls -d */); do
    ( stow --target=$HOME --restow $d )
  done
}

install-packages() {
  echo "Installing packages from packages.txt..."
  sudo pacman -Sy yaourt
  yaourt -S --needed --noconfirm `cat packages.txt`
}

add-repositories() {
  echo "Adding repositories from repositories.txt..."
  add-infinality-key
  cat repositories.txt | sudo tee -a /etc/pacman.conf
}

add-infinality-key() {
  sudo dirmngr &
  sleep 1
  sudo pacman-key -r 962DDE58
  sudo pacman-key --lsign-key 962DDE58
}

enable-services() {
  echo "Enabling systemctl services..."
  sudo systemctl enable tlp tlp-sleep connman
  # sudo systemctl disable systemd-rfkill
  sudo tlp start
}

set-shell() {
  echo "Setting shell to zsh..."
  chsh -s $(which zsh)
}

show-post-install() {
  echo "... bootstrapped successfully!"
}

bootstrap() {
  add-repositories
  install-packages
  enable-services
  link-config
  set-shell
  show-post-install
}

# runtime
#########

if [ $# -eq 0 ]; then
  display_help 1
else
  while [ $# -ne 0 ]; do
    case $1 in
      -h|--help|help)    display_help ;;
      link-config)       runstr="link-config" ;;
      install-packages)  runstr="install-packages" ;;
      bootstrap)         runstr="bootstrap" ;;
      *)                 echo "invalid option: $1" ; display_help 1 ;;
    esac
    shift
  done

  $runstr
  exit $?
fi
