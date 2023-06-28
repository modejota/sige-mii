#!/bin/bash

# update indices
sudo apt update -qq -y
# install two helper packages we need
sudo apt install --no-install-recommends software-properties-common dirmngr -y
# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
# Install R-base
sudo apt install --no-install-recommends r-base -y

# Install R-Studio
wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.03.0-386-amd64.deb
sudo apt install -f ./rstudio-2023.03.0-386-amd64.deb
rm rstudio-2023.03.0-386-amd64.deb