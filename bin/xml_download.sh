#!/bin/bash
#set -e

xml_url=https://github.com/revuloj/revo-fonto/archive/master.zip

echo "master.zip <- ${xml_url}"
curl -L -H "Accept: application/zip" -o master.zip "${xml_url}"

# ni forigas dosierojn en xml por esti certa, ne konsideri malnovajn doseriojn
rm xml/*

# -j = no dirs, -q = quiet, -o = overwrite existing, -u update as needed (unzip -juqo...)
unzip -jq master.zip -d xml/ "revo-fonto-master/revo/*.xml" \
  && rm -rf revo-fonto-master && rm master.zip

