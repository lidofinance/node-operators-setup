#!/usr/bin/env bash

set -e
set -u
set -o pipefail

export ANSIBLE_FORCE_COLOR="True"

# Description:
# Shell script for initiall cofiguration to deploy all needed software
#
# Run as
# curl -L https://raw.githubusercontent.com/path_to_script | bash -s

# ENVs
. /etc/os-release
DATE=$(date +%T_%d-%m-%Y)
LOG_FILE="installation.log"
REPO_NAME="node-operators-setup"
CUSTOM_INVENTORY="variables"

# SSH ENVs
CURRENT_USERNAME=$(whoami)
PRIVATE_KEY=~/.ssh/id_rsa
PUB_KEY=~/.ssh/id_rsa.pub
KNOWN_HOSTS=~/.ssh/known_hosts

# SECRET ENVs
PREGEN_SECRETS="jwtsecret.hex"
SECRETS_FILE="secret_variables"

# Functions
check_os_version() {
  if [ ${ID} == "ubuntu" ]; then
    case ${VERSION_ID} in
    20.04 | 22.04)
      echo -ne "${DATE} ${PRETTY_NAME} is supported\n"
      echo -ne "\n"
      ;;
    *)
      echo -ne "${PRETTY_NAME} is not supported by this script\n"
      echo -ne "\n"
      exit 2
      ;;
    esac
  fi
}

# Preparing SSH connection
check_local_ssh_key() {
  if [ -f ${PRIVATE_KEY} ] && [ -f ${PUB_KEY} ]; then
    echo -ne "${DATE} Public key -> ${PUB_KEY} <- exists\n"
    echo -ne "\n"
  elif [ -f ${PRIVATE_KEY} ]; then
    echo -ne "${DATE} Generating public key from current private key\n"
    echo -ne "\n"
    ssh-keygen -f ${PRIVATE_KEY} -y >${PUB_KEY}
  else
    echo -ne "${DATE} Generating new private and public key\n"
    echo -ne "\n"
    ssh-keygen -b 4096 -t rsa -f ${PRIVATE_KEY} -q -N ""
  fi
}

export_custom_envs() {
  export ETHEREUM_NODES_IP=${ETHEREUM_NODES_IP}
  export VALIDATORS_EJECTOR_IP=${VALIDATORS_EJECTOR_IP}
  export MONITORING_SERVER_IP=${MONITORING_SERVER_IP}
  export VALIDATOR_EJECTOR_LOCATOR_ADDRESS=${VALIDATOR_EJECTOR_LOCATOR_ADDRESS}
  export VALIDATOR_EJECTOR_STAKING_MODULE_ID=${VALIDATOR_EJECTOR_STAKING_MODULE_ID}
  export VALIDATOR_EJECTOR_OPERATOR_ID=${VALIDATOR_EJECTOR_OPERATOR_ID}
  export TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
  export TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}
}

export_pregen_secrets() {
  export JWT_TOKEN=${JWT_TOKEN}
}

export_secrets() {
  export ALERTS_BOX_GRAFANA_USER=${ALERTS_BOX_GRAFANA_USER}
  export ALERTS_BOX_GRAFANA_PASSWORD=${ALERTS_BOX_GRAFANA_PASSWORD}
  export LIDO_KEYS_API_DB_PASSWORD=${LIDO_KEYS_API_DB_PASSWORD}
}

add_host_keys_to_known_host() {
  ssh-keyscan -t ssh-rsa ${ETHEREUM_NODES_IP} >>${KNOWN_HOSTS}
  ssh-keyscan -t ssh-rsa ${VALIDATORS_EJECTOR_IP} >>${KNOWN_HOSTS}
  ssh-keyscan -t ssh-rsa ${MONITORING_SERVER_IP} >>${KNOWN_HOSTS}
  sort ${KNOWN_HOSTS} | uniq >${KNOWN_HOSTS}.uniq
  mv ${KNOWN_HOSTS}{.uniq,}
}

check_custom_inventory_existence() {
  if [ -f ${CUSTOM_INVENTORY} ]; then
    echo -ne "${DATE} File -> ${CUSTOM_INVENTORY} <- exists\n"
    echo -ne "\n"
    source ${CUSTOM_INVENTORY}
    export_custom_envs
    add_host_keys_to_known_host
  else
    echo -ne "${DATE} You have to provide -> ${CUSTOM_INVENTORY} <- file\n"
    echo -ne "\n"
    exit 2
  fi
}

check_gen_secret_variables() {
  if [ -s ${SECRETS_FILE} ]; then
    echo -ne "${DATE} File -> ${SECRETS_FILE} <- exists\n"
    source ${SECRETS_FILE}
    if [ -z $ALERTS_BOX_GRAFANA_USER ]; then
      echo "no defined ALERTS_BOX_GRAFANA_USER variable"
      exit 2
    fi
    if [ -z $ALERTS_BOX_GRAFANA_PASSWORD ]; then
      echo "no defined ALERTS_BOX_GRAFANA_PASSWORD variable"
      exit 2
    fi
    if [ -z $LIDO_KEYS_API_DB_PASSWORD ]; then
      echo "no defined LIDO_KEYS_API_DB_PASSWORD variable"
      exit 2
    fi
    echo "ALERTS_BOX_GRAFANA_USER, ALERTS_BOX_GRAFANA_PASSWORD, LIDO_KEYS_API_DB_PASSWORD exist and have value"
    echo -ne "\n"
  else
    echo "ALERTS_BOX_GRAFANA_USER=operator-$(openssl rand -base64 5 | tr -d "=+/" | cut -c1-4)" >${SECRETS_FILE}
    echo "ALERTS_BOX_GRAFANA_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-29)" >>${SECRETS_FILE}
    echo "LIDO_KEYS_API_DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-29)" >>${SECRETS_FILE}
  fi
  source ${SECRETS_FILE}
  export_secrets
}

check_pregen_secrets() {
  if [ -s ${PREGEN_SECRETS} ]; then
    echo -ne "${DATE} File -> ${PREGEN_SECRETS} <- exists\n"
    echo -ne "\n"
    source ${PREGEN_SECRETS}
    export_pregen_secrets
  else
    echo -ne "${DATE} Generating secrets\n"
    echo -ne "\n"
    echo "JWT_TOKEN=$(openssl rand -hex 32 | tr -d "\n")" >${PREGEN_SECRETS}
    source ${PREGEN_SECRETS}
    export_pregen_secrets
  fi
}

install_ansible() {
  echo "${DATE} Checking if Ansible is already installed"
  if hash ansible 2>/dev/null; then
    echo -ne "${DATE} Ansible is already installed\n"
    echo -ne "\n"
  else
    echo -ne "${DATE} Adding Ansible PPA\n"
    sudo apt-add-repository ppa:ansible/ansible -y
    echo -ne "${DATE} Installing Ansible\n"
    sudo apt-get update
    sudo apt-get install software-properties-common ansible -y
  fi
}

install_git() {
  echo -ne "${DATE} Checking if Git is already installed\n"
  if hash git 2>/dev/null; then
    echo -ne "${DATE} Git is already installed\n"
    echo -ne "\n"
  else
    echo -ne "${DATE} Installing Git\n"
    sudo apt-get install git -y
  fi
}

install_openssl() {
  echo -ne "${DATE} Checking if openssl is already installed\n"
  if hash openssl 2>/dev/null; then
    echo -ne "${DATE} openssl is already installed\n"
    echo -ne "\n"
  else
    echo -ne "${DATE} Installing openssl\n"
    sudo apt-get install openssl -y
  fi
}

clone_repo() {
  echo -ne "${DATE} Cloning repository with ansible roles\n"
  echo -ne "\n"
  if [ ! -d ${REPO_NAME} ]; then
    # NOW WE HAVE TO AUTHENTICATE SINCE IT'S A PRIVATE REPO
    git clone https://github.com/lidofinance/${REPO_NAME}
  else
    rm -rf ${REPO_NAME}
    git clone https://github.com/lidofinance/${REPO_NAME}
  fi
}

ansible_initial_run() {
  set +e
  if [ -f node-operators-setup/ansible/inventories/${ENVIRONMENT}.yml ]; then
    ansible all -i node-operators-setup/ansible/inventories/${ENVIRONMENT}.yml -m ping
  else
    echo "No inventory file for ${ENVIRONMENT} environment"
    exit 2
  fi
  if [ $? -eq 0 ]; then
    echo -ne "${DATE} SSH connection by Ansible is succesful\n"
    echo -ne "\n"
  else
    echo -ne "${DATE} SSH connection by Ansible isn't successful\n"
    echo -ne "${DATE} Running Ansible to configure access by SSH\n"
    echo -ne "\n"
    if [ -f node-operators-setup/ansible/inventories/${ENVIRONMENT}.yml ]; then
      ansible-playbook -i ${REPO_NAME}/ansible/inventories/${ENVIRONMENT}.yml --ask-pass \
        ${REPO_NAME}/ansible/playbooks/configure_ssh_access.yml \
        -e "my_username=${CURRENT_USERNAME}" \
        -e "my_public_key=\"$(cat $PUB_KEY)\""
    else
      echo "No inventory file for ${ENVIRONMENT} environment"
      exit 2
    fi
  fi
  set -e
}

ansible_run() {
  echo -ne "${DATE} Running Ansible with tag ${1}\n"
  export ANSIBLE_ROLES_PATH=${REPO_NAME}/ansible/roles/
  if [ -f node-operators-setup/ansible/inventories/${ENVIRONMENT}.yml ]; then
    ansible-playbook -i ${REPO_NAME}/ansible/inventories/${ENVIRONMENT}.yml \
      ${REPO_NAME}/ansible/playbooks/site.yml \
      -t ${1}
  else
    echo "No inventory file for ${ENVIRONMENT} environment"
    exit 2
  fi
}

main() {
  echo -ne "${DATE} Starting installation script\n"
  check_os_version
  check_gen_secret_variables
  check_local_ssh_key
  check_custom_inventory_existence
  install_ansible
  install_git
  install_openssl
  check_pregen_secrets
  clone_repo
  ansible_initial_run
  ansible_run common
  ansible_run alerts-box
  ansible_run services
  ansible_run nodes
  echo -ne "${DATE} Installation script ended\n"
}

main | tee -a ${LOG_FILE}
