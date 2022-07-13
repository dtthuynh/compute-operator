#!/bin/bash

# Copyright Red Hat

set -e

# Install go
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
fi

mkdir -p /go/{bin,pkg,src} /go/pkg/cache /opt/go
chmod -R a+rwx /go
cd /opt/go
wget --progress=dot:mega https://dl.google.com/go/go${GOVERSION}.${OS}-${ARCH}.tar.gz
tar -C /usr/local -xzf go${GOVERSION}.${OS}-${ARCH}.tar.gz
rm -rf /opt/go
if [ "$ARCH" = "s390x" ]; then
        cd /usr/bin
        ln gcc s390x-linux-gnu-gcc
fi

## Need kustomize too!
KUSTOMIZE_TMP_DIR=$(mktemp -d)
cd $KUSTOMIZE_TMP_DIR
#-- older way
#KUSTOMIZE_VERSION=3.2.3
#curl --silent --location --remote-name "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_kustomize.v${KUSTOMIZE_VERSION}_${OS}_${ARCH}"
#chmod a+x kustomize_kustomize.v${KUSTOMIZE_VERSION}_${OS}_${ARCH}
#mv kustomize_kustomize.v${KUSTOMIZE_VERSION}_${OS}_${ARCH} /usr/local/bin/kustomize
#-- newer way
KUSTOMIZE_VERSION=3.8.7
curl -sLO "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${OS}_${ARCH}.tar.gz"
tar xzf ./kustomize_v*_${OS}_${ARCH}.tar.gz
cp ./kustomize "/usr/local/bin/kustomize"

ls -alh /usr/local/bin/kustomize
which kustomize
kustomize

echo "Installing cm-cli..."
curl -kLo cm.tar.gz https://github.com/stolostron/cm-cli/releases/download/v1.0.14/cm_linux_amd64.tar.gz
mkdir cm-unpacked
tar -xzf cm.tar.gz -C cm-unpacked
chmod 755 ./cm-unpacked/cm_linux_amd64/cm
mv ./cm-unpacked/cm_linux_amd64/cm /usr/local/bin/cm
cm version