FROM ethereum/client-go:v1.10.1

ARG ACCOUNT_PASSWORD

COPY ./genesis.json ./genesis.json
COPY ./deploy-contract.js ./deploy-contract.js
COPY ./contract-details.js ./contract-details.js

RUN geth init ./genesis.json \
    && rm -f ~/.ethereum/geth/nodekey \
    && echo ${ACCOUNT_PASSWORD} > ./password.txt \
    && geth account new --password ./password.txt \
    && rm -f ./password.txt

ENTRYPOINT ["geth"]