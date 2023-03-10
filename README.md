# Lido-node-operators-setup

### System requirements

- OS Ubuntu 20.04
- Hosts
  - ethereum_nodes (8CPU, 32RAM, 1,5Tb)
  - validators_ejector (1CPU, 8RAM, 50Gb)
  - monitoring_server (2CPU, 8RAM, 50Gb)

Also, we recommend having a data of nodes and system on different volumes. In other words /srv should be a separate volume

### Installation

1. First of all, you need - to get three servers.

   - Host for `geth` and `lighthouse` nodes
   - Host for `validator-ejector` and `keys-api` services
   - Host for monitoring system `alert-box`

2. Prepare conf file

   - Login to monitoring_server
   - Download conf file to monitoring server - Run command `curl https://raw.githubusercontent.com/lidofinance/node-operators-setup/master/variables --output variables`
   - Fill out conf variables in file `variables`
     - ETHEREUM_NODES_IP - IP address of your ethereum_nodes host
     - VALIDATORS_EJECTOR_IP - IP address of your validators_ejector host
     - MONITORING_SERVER_IP - IP address of your monitoring_server host
     - ALERTS_BOX_GRAFANA_USER - desired grafana username
     - ALERTS_BOX_GRAFANA_PASSWORD desired grafana password
     - TELEGRAM_BOT_TOKEN - Token of your telegram bot
     - TELEGRAM_CHAT_ID - chat_id of your channel for alerts

3. Run installation
   - Login to monitoring_server
   - Run command `curl -L https://raw.githubusercontent.com/lidofinance/node-operators-setup/master/base.sh | bash -s`

### TODO

- Add additional dashboards
- Add alerts to alertmanager
- Tests
- Mount extra disks
- Remove extra variables from logs block
