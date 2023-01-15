#!/bin/bash
#
# Inputs:
#
# SERVER_NAME = routeable FQDN from agents/browsers POV
# 
TIMESTAMP=`date +"%Y%m%d.%H%M%S"`
TIMESTAMPED_CONFIG=/velociraptor/config/server.config.${TIMESTAMP}.yaml
OVERRIDES_FILE=`mktemp`

cat > ${OVERRIDES_FILE} <<EOM
{
  "Client": {
    "server_urls": [
      "https://${SERVER_NAME}:8000/"
    ],
    "pinned_server_name": "${SERVER_NAME}",
    "ca_certificate": "`cat /velociraptor/certs/ca.pem | sed 's/$/\\\\n/g' | tr -d '\n'`"
  },
  "Frontend": {
    "hostname": "${SERVER_NAME}",
    "certificate": "`cat /velociraptor/certs/server.pem | sed 's/$/\\\\n/g' | tr -d '\n'`",
    "private_key": "`openssl rsa -traditional -in /velociraptor/certs/server.key -out - | sed 's/$/\\\\n/g' | tr -d '\n'`"
  },
  "API": {
    "bind_address": "0.0.0.0",
    "pinned_gw_name": "${SERVER_NAME}",
    "hostname": "${SERVER_NAME}"
  },
  "GUI": {
    "public_url": "https://${SERVER_NAME}",
    "bind_address": "0.0.0.0",
    "bind_port": 443,
    "gw_certificate": "`cat /velociraptor/certs/server.pem | sed 's/$/\\\\n/g' | tr -d '\n'`",
    "gw_private_key": "`openssl rsa -traditional -in /velociraptor/certs/server.key -out - | sed 's/$/\\\\n/g' | tr -d '\n'`",
    "links": [
      {
        "text": "Agent Downloads",
        "url": "http://${SERVER_NAME}:9000",
        "new_tab": true
      }
    ]
  },
  "Monitoring": { "bind_address": "0.0.0.0" },
  "Datastore": {
    "location": "/velociraptor/datastore",
    "filestore_directory": "/velociraptor/filestore"
  },
  "initial_orgs": [
    {
      "org_id": "O1234",
      "name": "JanT",
      "nonce": "289327498237498234kyjhdfkasjhd"
    }
  ]
}
EOM

# generate server configuration
./velociraptor config generate --merge_file=${OVERRIDES_FILE} > ${TIMESTAMPED_CONFIG}

# symlink config
ln -sf ${TIMESTAMPED_CONFIG} /velociraptor/config/server.config.yaml

./velociraptor --config /velociraptor/config/server.config.yaml user add ${VELOX_USER} ${VELOX_PASSWORD} --role ${VELOX_ROLE}

# Re-generate client config in case server config changed
./velociraptor --config /velociraptor/config/server.config.yaml config client > /velociraptor/config/client.config.yaml

# Repack clients
mkdir -p /velociraptor/clients/repacked/linux
mkdir -p /velociraptor/clients/repacked/mac
mkdir -p /velociraptor/clients/repacked/windows

./velociraptor config repack --exe /velociraptor/clients/linux/velociraptor_client \
  /velociraptor/config/client.config.yaml \
  /velociraptor/clients/repacked/linux/velociraptor_client_repacked

./velociraptor config repack --exe /velociraptor/clients/mac/velociraptor_client \
  /velociraptor/config/client.config.yaml \
  /velociraptor/clients/repacked/mac/velociraptor_client_repacked

./velociraptor config repack --exe /velociraptor/clients/windows/velociraptor_client.exe \
  /velociraptor/config/client.config.yaml \
  /velociraptor/clients/repacked/windows/velociraptor_client_repacked.exe

msipkgtmp=`mktemp -d`

cp -fv /velociraptor/clients/windows/*.msi ${msipkgtmp}/velociraptor.msi
cp -fv /velociraptor/config/client.config.yaml ${msipkgtmp}/velociraptor.yaml
zip -j /velociraptor/clients/repacked/windows/velociraptor-agent-msi-with-config.zip ${msipkgtmp}/*
cp -fv /velociraptor/config/client.config.yaml /velociraptor/clients/repacked/windows/client.config.yaml
cp -fv /velociraptor/config/client.config.yaml /velociraptor/clients/repacked/linux/client.config.yaml
cp -fv /velociraptor/config/client.config.yaml /velociraptor/clients/repacked/macos/client.config.yaml
cp -fv /velociraptor/config/client.config.yaml /velociraptor/clients/repacked/client.config.yaml

# Start Velociraptor
./velociraptor --config /velociraptor/config/server.config.yaml frontend -v
