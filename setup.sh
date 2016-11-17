#!/usr/bin/env bash

brews=(
  node --with-full-icu
  wget
  homebrew/versions/maven32
)

casks=(
)

pips=(
  pip
  awscli
)

gems=(
  bundle
)

######################################## End of app list ########################################
set +e
set -x

if test ! $(which brew); then
  echo "Installing Xcode ..."
  xcode-select --install

  echo "Installing Homebrew ..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Updating Homebrew ..."
  brew update
  brew upgrade
fi
brew doctor
brew tap homebrew/dupes

fails=()

function print_red {
  red='\x1B[0;31m'
  NC='\x1B[0m' # no color
  echo -e "${red}$1${NC}"
}

function install {
  cmd=$1
  shift
  for pkg in $@;
  do
    exec="$cmd $pkg"
    echo "Executing: $exec"
    if $exec ; then
      echo "Installed $pkg"
    else
      fails+=($pkg)
      print_red "Failed to execute: $exec"
    fi
  done
}

echo "Installing ruby ..."
brew install ruby-install chruby
ruby-install ruby-2.2.1
ruby-install ruby-1.9.3-p551

echo "source /usr/local/share/chruby/chruby.sh" >> ~/.bash_profile
echo "source /usr/local/share/chruby/auto.sh" >> ~/.bash_profile

source ~/.bash_profile
chruby ruby-2.2.1
ruby -v

echo "Installing Java 1.6..."
brew cask install java6

echo "Installing packages ..."
brew info ${brews[@]}
install 'brew install' ${brews[@]}

echo "Tapping casks ..."
brew tap caskroom/fonts
brew tap caskroom/versions

echo "Installing software ..."
brew cask info ${casks[@]}
install 'brew cask install' ${casks[@]}

echo "Installing secondary packages ..."
# TODO: add info part of install or do reinstall?
install 'pip install --upgrade' ${pips[@]}
install 'gem install' ${gems[@]}

echo "Cleaning up ..."
brew cleanup
brew cask cleanup
brew linkapps

for fail in ${fails[@]}
do
  echo "Failed to install: $fail"
done


echo "Done!"
