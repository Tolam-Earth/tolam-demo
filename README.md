# Introduction
This document provides instructions to deploy and use a Tolam Earth environment.  This includes the Marketplace UI, the Marketplace services, Integration services, and ARMM.

# Preparation
To operate the exchange, you will need the following:
- One or more Hedera testnet accounts, obtainable from https://portal.hedera.com/register  Consider unique accounts for the following roles:
    - Registry/Guardian
    - Smart Contract Administrator
    - Offset Seller
    - Offset Buyer
    - Exchange
    - AARM Buyer
- A Ledger Works API key available from https://www.lworks.io/eco which is used to obtain an offset's ESG data
- An operating instance of the Guardian https://github.com/hashgraph/guardian
    - One or more Guardian-minted offsets using a supported policy.  A suitable example policy file is included in this repository
    - Verification that ESG data is available for your offset(s) via Ledger Works https://explore.lworks.io/
- A suitable smart contract deployed to Hedera testnet.  To create one, get the "demo" tagged code at https://github.com/Tolam-Earth/integration-smart-contracts and follow steps 1-3 of the readme
- The HashPack wallet browser plugin https://www.hashpack.app/

# Setup Tools
To build and deploy, you will need the following tools:
- Java 17
- Docker and docker-compose that can support a version 3.8 config file.
    - Make sure your docker daemon is running.  As some of the steps below will interact with docker, your user will need to be in the docker group or the scripts run with sudo.
- npm (tested with v8.19.2) and Node.js (tested with v18.12.1)

# Standup Environment
## Step 1 - Get Code
This repository includes a script that will download the needed repositories at a commit called "demo":

```
./get-tolam-repos.sh
```

This will give you the following repositories:
- marketplace-build
- integration-services
- armm-services
- armm-data-engineering

While not required to operate the Tolam Earth environment, you may also want to download the following:
- integration-smart-contracts contains code deploying smart contracts and other utilities
- e2e-testing contains test code for validating the environment


## Step 2 - Build
Build the components

- marketplace-build  
    This repo does not contain the actual code, but includes scripts to retreive the marketplace-services and marketplace-ui repos, build, and package them into a single container image.  
    
    Note that because the UI is being statically built, several environment variables must be set in the shell:
    ```
    export VITE_HEDERA_ENV=testnet
    export VITE_SMART_CONTRACT_ID=...contract id...
    export VITE_API_ROOT_URL=/hem/v1
    ```
    Run the following sequence of commands to download the code, build, and create the container:
    ```
    ./checkout-repos.sh
    ./build.sh
    ```

- integration-services
    From the root directory of the repository, run
    ```bash
    ./gradlew dockerBuild
    ```

- armm-services
    From the root directory of the repository, run
    ```bash
    ./gradlew dockerBuild
    ```


- armm-data-engineering

    From the root directory of the repository, run
    ```bash
    docker build -f services/nft_base/Dockerfile -t nft-base .
    docker build -f services/nft_transformer/Dockerfile -t nft-transformer .
    docker build -f services/nft_classifier/Dockerfile -t nft-classifier .
    docker build -f services/nft_pricing/Dockerfile -t nft-pricing .
    ```

## Step 3 - Configure Environment
Copy or rename the included docker-compose.yml.example file to docker-compose.yml

There are a number of variables that need to be set in docker-compose.yml before deployment.

In the marketplace section, set the following variables:
```
    HEM_HEDERA_OPERATOR_ID=<Hedera ID for Marketplace operator>
    HEM_HEDERA_PRIVATE_KEY=<Private key for Marketplace operator>
    HEM_HEDERA_OFFSETS_CONTRACT_ID=<Smart contract ID>
    HEM_LWORKS_API_KEY=<API key from Ledger Works>
```
In the integration_orchestrator section, set the following variables:
```
    LEDGER_WORKS_API_KEY=<API key from Ledger Works>
    HEM_OFFSETS_CONTRACT_ID=<Smart contract ID - should match Marketplace>
    TOKEN_DISCOVERY_TOKEN_IDS=<Comma-separated list of Hedera token IDs for polling Ledger Works>
# buyer info only required if using the automated buying function of ARMM
    BUYER_OPERATOR_ID=<Hedera ID for automated buyer>
    BUYER_PRIVATE_KEY=<Private key for automated buyer>
```



## Step 4 - Deploy
After setting variables in the docker-compose.yml file, run
   
```
docker compose up -d
```
 This will pull any additional docker images (i.e. pubsub emulator, PostgreSQL, etc.) and start the components.

 Be sure all services are in a "Healthy" or "Started" state.

Optional tests are availalble at https://github.com/Tolam-Earth/e2e-testing


## Step 5 - Try It
Exchange demo operation is documented in [TolamEarthHowTo.pdf](TolamEarthHowTo.pdf)

ARMM automated trading is documented in [AutomatedTradingARMM.pdf](AutomatedTradingARMM.pdf)



