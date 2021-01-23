#!/bin/bash

#
# (c) Decker, 2018
#

STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo "Installing an explorer for komodo in the current directory: $CUR_DIR"

echo -e "$STEP_START[ * ]$STEP_END Modifying komodo's '.conf' file at $HOME/.komodo/komodo.conf"



. $HOME/.komodo/komodo.conf

rpcport=7771
zmqport=$((rpcport+2))
webport=$((rpcport+3))

rm $HOME/.komodo/komodo.conf

mkdir -p $HOME/.komodo
touch $HOME/.komodo/komodo.conf
cat <<EOF > $HOME/.komodo/komodo.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:$zmqport
zmqpubhashblock=tcp://127.0.0.1:$zmqport
rpcallowip=127.0.0.1
rpcport=$rpcport
rpcuser=$rpcuser
rpcpassword=$rpcpassword
uacomment=bitcore
showmetrics=0
rpcworkqueue=256
EOF




echo -e "$STEP_START[ * ]$STEP_END Installing explorer for komodo"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
nvm use v4

$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node create komodo-explorer
cd komodo-explorer
$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/gaeacodes/insight-api-komodo git+https://git@github.com/gaeacodes/insight-ui-komodo

cd $CUR_DIR/komodo-explorer/node_modules/insight-api-komodo
npm install moment

cd $CUR_DIR

cat << EOF > $CUR_DIR/komodo-explorer/bitcore-node.json
{
  "network": "mainnet",
  "port": $webport,
  "services": [
    "bitcoind",
    "insight-api-komodo",
    "insight-ui-komodo",
    "web"
  ],
  "servicesConfig": {
    "bitcoind": {
      "connect": [
        {
          "rpchost": "127.0.0.1",
          "rpcport": $rpcport,
          "rpcuser": "$rpcuser",
          "rpcpassword": "$rpcpassword",
          "zmqpubrawtx": "tcp://127.0.0.1:$zmqport"
        }
      ]
    },
  "insight-api-komodo": {
    "rateLimiterOptions": {
      "whitelist": ["::ffff:127.0.0.1","127.0.0.1"],
      "whitelistLimit": 500000, 
      "whitelistInterval": 3600000 
    }
  }
  }
}

EOF

# creating launch script for explorer
cat << EOF > $CUR_DIR/komodo-explorer-start.sh
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
cd komodo-explorer
nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start
EOF
chmod +x komodo-explorer-start.sh


echo -e "$STEP_START[ * ]$STEP_END Execute komodo-explorer-start.sh to start the explorer"
  
echo -e "$STEP_START[ * ]$STEP_END Visit http://localhost:$webport on your computer to access the explorer after starting it"
