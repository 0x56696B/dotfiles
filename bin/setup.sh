# _cmd performs commands with error checking
function _cmd {
  #create log if it doesn't exist
  if ! [[ -f $DOTFILES_LOG ]]; then
    touch $DOTFILES_LOG
  fi
  # empty conduro.log
  > $DOTFILES_LOG
  # hide stdout, on error we print and exit
  if eval "$1" 1> /dev/null 2> $DOTFILES_LOG; then
    return 0 # success
  fi
  # read error from log and add spacing
  printf "${OVERWRITE}${LRED} [X]  ${TASK}${LRED}\n"
  while read line; do
    printf "      ${line}\n"
  done < $DOTFILES_LOG
  printf "\n"
  # remove log file
  rm $DOTFILES_LOG
  # exit installation
  exit 1
}

function ubuntu_setup() {
  if ! dpkg -s ansible >/dev/null 2>&1; then
    echo "Installing Ansible"
    _cmd "sudo apt-get update"
    _cmd "sudo apt-get install -y software-properties-common"
    _cmd "sudo apt-add-repository -y ppa:ansible/ansible"
    _cmd "sudo apt-get update"
    _cmd "sudo apt-get install -y ansible"
    _cmd "sudo apt-get install python3-argcomplete"
    _cmd "sudo activate-global-python-argcomplete3"
  fi
  if ! dpkg -s python3 >/dev/null 2>&1; then
    echo "Installing Python3"
    _cmd "sudo apt-get install -y python3"
  fi
  if ! dpkg -s python3-pip >/dev/null 2>&1; then
    echo "Installing Python3 Pip"
    _cmd "sudo apt-get install -y python3-pip"
  fi
  # if ! pip3 list | grep watchdog >/dev/null 2>&1; then
  #   echo "Installing Python3 Watchdog"
  #   _cmd "pip3 install watchdog"
  # fi
}

function arch_setup() {
  if ! [ -x "$(command -v ansible)" ]; then
    echo "Installing Ansible"
    _cmd "sudo pacman -Sy --noconfirm"
    _cmd "sudo pacman -S --noconfirm ansible"
    _cmd "sudo pacman -S --noconfirm python-argcomplete"
    # _cmd "sudo activate-global-python-argcomplete3"
  fi
  if ! pacman -Q python3 >/dev/null 2>&1; then
    echo "Installing Python3"
    _cmd "sudo pacman -S --noconfirm python3"
  fi
  if ! pacman -Q python-pip >/dev/null 2>&1; then
    echo "Installing Python3 Pip"
    _cmd "sudo pacman -S --noconfirm python-pip"
  fi
  if ! pip3 list | grep watchdog >/dev/null 2>&1; then
    echo "Installing Python3 Watchdog"
    _cmd "sudo pacman -S --noconfirm python-watchdog"
  fi

  if ! pacman -Q openssh >/dev/null 2>&1; then
    echo "Installing OpenSSH"
    _cmd "sudo pacman -S --noconfirm openssh"
  fi

  echo "Setting Locale"
  _cmd "sudo localectl set-locale LANG=en_US.UTF-8"
}

function load_setup() {
  source /etc/os-release
  echo "Loading Setup for detected OS: $ID"
  case $ID in
    ubuntu)
      ubuntu_setup
      ;;
    arch)
      arch_setup
      ;;
    *)
      _cmd "echo 'Unsupported OS'"
      ;;
  esac
}

export -f load_setup
