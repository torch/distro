#!/bin/bash
# This script installs a basic build environment for debian/ubuntu
ACTION="${1}"
ARGS="${#}"

UBUNTU_VERSION="trusty"

INSTALL_PACKAGES=(
    apt-file
    cdebootstrap
    cowdancer
    cowbuilder
    debhelper
    dput
    dpkg-dev
    dpkg-sig
    debootstrap
    devscripts
    dpatch
    fakeroot
    git-buildpackage
    libdistro-info-perl
    libtool
    pbuilder
    quilt
    ubuntu-dev-tools
    util-linux
)

set -e

###############################
# Functions                   #
###############################

### Die function
die() { echo -e "Error in $0: $1"; exit 1; }

### Ask for confirmation
_confirm() {
    echo -e "\n$(date) - WARNING: $1"
    read -p "Are you sure you want to continue? [N/y]" IN
    if [ "${IN}" == "y" ] || [ "${IN}" == "Y" ] || [ "${IN}" == "yes" ]; then
        return 0
    else
        echo "Canceled!"
        exit 0
    fi
}

### Create an ubuntu cow for the given distribution
_create_ubuntu_cow() {
    _confirm "Creating a $1 cow right now!"
    export DIST="$1"
    export BASE="/var/cache/pbuilder/base-$DIST/"
    git-pbuilder create
}

### Install all required packages
_install_packages() {
    _confirm "Installing packages..."
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes ${INSTALL_PACKAGES[@]}
}

### Create a pbuilder configuration file
_create_pbuilder_config() {
    [ -f /etc/pbuilderrc ] && mv /etc/pbuilderrc /etc/pbuilderrc.old

    cat << EOF > /etc/pbuilderrc

    export HOOKDIR=/etc/git-buildpackage/hooks
    export DEBBUILDOPTS=-j4
    export DEBOOTSTRAPOPTS=( '--variant=buildd' '--keyring' '/usr/share/keyrings/ubuntu-archive-keyring.gpg' )

    export DIST=\$(dpkg-parsechangelog | awk '/^Distribution: / {print \$2}')
    export BASE="/var/cache/pbuilder/base-\$DIST/";

    export BUILDRESULT="/var/cache/pbuilder/\$DIST/result/"
    export APTCACHE="/var/cache/pbuilder/\$DIST/aptcache/"
    export BUILDPLACE="/var/cache/pbuilder/build/"

    export DISTRIBUTION="\$DIST"
    export MIRRORSITE="http://nl.archive.ubuntu.com/ubuntu/"
    export COMPONENTS="main restricted universe"
EOF
}

### Create hooks that are run pre build inside the cow environment
_create_pbuilder_hooks() {
    [ ! -d /etc/git-buildpackage/hooks ] && mkdir -p /etc/git-buildpackage/hooks

    cat << EOF > /etc/git-buildpackage/hooks/D40-speedup-hacks

    # speedup apt
    echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/02apt-speedup

    echo 'Acquire::PDiffs false;'         >> /etc/apt/apt.conf
    echo 'Acquire::ForceIPv4 true;'       >> /etc/apt/apt.conf
    echo 'APT::Install-Recommends false;' >> /etc/apt/apt.conf
    echo 'APT::Install-Suggests false;'   >> /etc/apt/apt.conf
EOF

    cat << EOF > /etc/git-buildpackage/hooks/D50-setup-cow-apt

    # Install dependencies for installing from a custom repository
    # DEBIAN_FRONTEND=noninteractive apt-get install --yes wget apt-transport-https ca-certificates

    # Add private repository
    # wget -4 -O - https://apt.somerepo.com/repo/repository_key }} | apt-key add -
    # echo "deb https://apt.somerepo.com unstable main" | tee /etc/apt/sources.list.d/custom_apt_repo.list

    apt-get update
EOF

}

### The setup function that configures a cowbuilder environment
_setup() {
    _install_packages
    _create_pbuilder_config
    _create_pbuilder_hooks
    _create_ubuntu_cow "${UBUNTU_VERSION}"
}

### Help function to show usage
_usage() {
      echo "Usage: $0 [setup|create_cow]"
      exit 0
}

###############################
# The main routine            #
###############################

### Check arguments
[ "${ARGS}" == 1 ] || _usage

if [ "${ACTION}" == "setup" ] ; then
    [ -d /etc/git-buildpackage/hooks ] && die "Allready installed!"
    _setup
elif [ "${ACTION}" == "create_cow" ] ; then
    [ -d /etc/git-buildpackage/hooks ] || die "Run $0 setup first!"
    _create_ubuntu_cow "${UBUNTU_VERSION}"
else
    _usage
fi