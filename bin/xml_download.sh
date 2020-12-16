
#!/bin/bash
#set -e

xml_url=https://github.com/revuloj/revo-fonto/archive/master.zip

echo "master.zip <- ${xml_url}"
curl -L -H "Accept: application/zip" -o master.zip "${xml_url}"

# -j = no dirs, -q = quiet, -o = overwrite existing, -u update as needed
unzip -juqo master.zip -d xml/ "revo-fonto-master/revo/*.xml" \
  && rm -rf revo-fonto-master && rm master.zip

