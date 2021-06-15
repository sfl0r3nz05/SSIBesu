# Besu Network

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Usage](#usage)
3. [Dev Network Setups](#dev-network-setups)
   1. [POA Network](#poa-network)
   2. [POA Network with Privacy](#poa-network-privacy)
   3. [Smart Contracts & DApps](#poa-network-dapps)

## Usage

**To start services and the network:**

`./run.sh` starts all the docker containers

**To stop services :**

`./stop.sh` stops the entire network, and you can resume where it left off with `./resume.sh`

`./remove.sh ` will first stop and then remove all containers and images

## Dev Network Setups

All our documentation can be found on the [Besu documentation site](https://besu.hyperledger.org/Tutorials/Examples/Private-Network-Example/).

Each quickstart setup is comprised of 4 validators, one RPC node and some monitoring tools like:

- [Alethio Lite Explorer](https://besu.hyperledger.org/en/stable/HowTo/Deploy/Lite-Block-Explorer/) to explore blockchain data at the block, transaction, and account level
- [Metrics monitoring](https://besu.hyperledger.org/en/stable/HowTo/Monitor/Metrics/) via Prometheus and Grafana to give you insights into how the chain is progressing (only with Besu based Quorum)
- Optional [logs monitoring](https://besu.hyperledger.org/en/latest/HowTo/Monitor/Elastic-Stack/) to give you real time logs of the nodes. This feature is enabled with a `-e` flag when starting the sample network

The overall architecture diagrams to visually show components of the blockchain networks is shown below.
**Consensus Algorithm**: The Besu based Quorum variant uses the `IBFT2` consensus mechanism.
**Private TX Manager**: The Besu based Quorum variant uses [Orion](https://github.com/PegaSysEng/orion)

### i. POA Network <a name="poa-network"></a>

This is the simplest of the networks available and will spin up a blockchain network comprising 4 validators, 1 RPC
node which has an [EthSinger](http://docs.ethsigner.consensys.net/) proxy container linked to it so you can optionally sign transactions. To view the progress
of the network, the Alethio block explorer can be used and is available on `http://localhost:25000`.
Hyperledger Besu based Quorum also deploys metrics monitoring via Prometheus available on `http://localhost:9090`,
paired with Grafana with custom dashboards available on `http://localhost:80`.

Essentially you get everything in the architecture diagram above, bar the yellow privacy block

Use cases:

- you are learning about how Ethereum works
- you are looking to create a Mainnet or Ropsten node but want to see how it works on a smaller scale
- you are a DApp Developer looking for a robust, simple network to use as an experimental testing ground for POCs.

### ii. POA Network with Privacy <a name="poa-network-privacy"></a>

This network is slightly more advanced than the former and you get everything from the POA network above and a few
Ethereum clients each paired with a Private Transaction Mananger. The Besu based Quorum variant uses [Orion](https://github.com/PegaSysEng/orion) for it's Private Transaction Mananger.

As before, to view the progress of the network, the Alethio block explorer can be used and is available on `http://localhost:25000`.
Hyperledger Besu based Quorum also deploys metrics monitoring via Prometheus available on `http://localhost:9090`,
paired with Grafana with custom dashboards available on `http://localhost:80`.

Essentially you get everything in the architecture diagram above.

Use cases:

- you are learning about how Ethereum works
- you are a user looking to execute private transactions at least one other party
- you are looking to create a private Ethereum network with private transactions between two or more parties.

Once the network is up and running you can send a private transaction between members and verify that other nodes do not see it.
Under the smart_contracts folder there is an `EventEmitter` contract which can be deployed and tested by running:

```
cd smart_contracts
npm install
node scripts/deploy.js
```

which deploys the contract and sends an arbitrary value (47) from `Member1` to `Member3`. Once done, it queries all three members (orion)
to check the value at an address, and you should observe that only `Member1` & `Member3` have this information as they were involved in the transaction
and that `Member2` responds with a `0x` to indicate it is unaware of the transaction.

```
node scripts/deploy.js
Creating contract...
Getting contractAddress from txHash:  0x10e8e9f46c7043f87f92224e065279638523f5b2d9139c28195e1c7e5ac02c72
Waiting for transaction to be mined ...
Contract deployed at address: 0x649f1dff9ca6dfbdd27135c94171334ea0fab5ee

Transaction Hash: 0x30b53a533afe909aee59df716e07f7003c0605075a13f97799b29cdd3c2c42a7
Waiting for transaction to be mined ...
Transaction Hash: 0x181e37e64cdfb8d3cb0f076ee63045981436f3273942bac47820c7ec1aad0c23
Transaction Hash: 0xa27db2772689fe8ca995d32d1753d2695421120c9f171d6d32eb0873f2b96466
Waiting for transaction to be mined ...
Waiting for transaction to be mined ...
Member3 value from deployed contract is: 0x000000000000000000000000000000000000000000000000000000000000002f
Member1 value from deployed contract is: 0x000000000000000000000000000000000000000000000000000000000000002f
Member2 value from deployed contract is: 0x
```

Further [documentation](https://besu.hyperledger.org/en/stable/Tutorials/Privacy/eeajs-Multinode-example/) for this example and a [video tutorial](https://www.youtube.com/watch?v=Menekt6-TEQ)
is also available.

There is an additional erc20 token example that you can also test with: executing `node example/erc20.js` deploys a `HumanStandardToken` contract and transfers 1 token to Node2.

This can be verified from the `data` field of the `logs` which is `1`.

### iii. Smart Contracts & DApps <a name="poa-network-dapps"></a>

- Once you have a network up and running from above, install [metamask](https://metamask.io/) as an extension in your browser
- Once you have setup your own private account, select 'My Accounts' by clicking on the avatar pic and then 'Import Account' and enter the valid private_key
- You can now deploy contracts and connect DApps to the network.

As seen in the architecture overview diagram you can extend the network with monitoring, logging, smart contracts, DApps and so on

As an example we've included the Truffle Pet-Shop Dapp in the `dapps` folder and here is a [video tutorial](https://www.youtube.com/watch?v=_3E9FRJldj8) you
can follow of deployment to the network and using it. Please import the private key `0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` to
Metmask **before** proceeding to build and run the DApp with `run-dapp.sh`. Behind the scenes, this has used a smart contract that is compiled and then
deployed (via a migration) to our test network. The source code for the smart contract and the DApp can be found in the folder `dapps/pet-shop`

When that completes open a new tab in your browser and go to `http://localhost:3001` which opens the Truffle pet-shop box app
and you can adopt a pet from there. NOTE: Once you have adopted a pet, you can also go to the block explorer `http://localhost:25000`
and search for the transaction where you can see its details recorded. Metamask will also have a record of any transactions.

### iV. On-chain Smart Contract

A continuación se añade información correspondiente al On chain Smart Contract. Para realizar las pruebas primero se debe copiar la version 6 del SmartContract en Remix, así como las librerías de las cuales hace uso. Habrá que cambiar las lineas import a las correctas, ya que las que están son las correspondientes a mi Remix. No se ha podido añadir la carpeta completa ya que Remix no permite el intercambio de archivos con el localhost. 

De momento haciendo uso de las siguientes líneas de texto y introduciendolas en la función proxy1 se ha conseguido lo siguiente:

INPUTS: 
(Las pruebas se han realizado con un punto extra al final de estos input, pero no debería ser un problema quitarlo. Si da error probar con punto al final del texto, es decir para el primer caso "... .12345.")

SETENTITY: "did:gatc:0x5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5","setEntity.did:gatc:0x5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5.12345"

GETENTITY:
"did:gatc:0x5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5","getEntity.did:gatc:0x5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5.mifirma.sha256"

SETDIDDOC:
"did:gatc:0x5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5","setDidDoc.did:gatc:0x5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5.12345.mifirma.sha256"

GETDIDDOC:
"did:gatc:0x5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5","getDidDoc.did:gatc:0x5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5.12345.mifirma.sha256"

Con estos inputs se ha conseguido:
1- Hacer un setEntity
2- Hacer un getEntity
3- Hacer un setDidDoc
4- Hacer un getDidDoc
5- Implementar seguridad contra falseos de identidad (solo la address que ha hecho set de la identidad puede recuperarla)
6- Implementar seguridad de relogeo de identidad (solo se puede hacer un set para cada address)

Se añade a continuación también con el fin de clarificar aún más el código el diagrama de clases:

![ClassDiagram_v06](https://user-images.githubusercontent.com/78016113/121688491-ceafe700-cac3-11eb-9638-6639ef703f53.png)
