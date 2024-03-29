#!/bin/bash

set -e

function fetch_from_instellar_or_fallback() {
  endpoint="$(curl -s --unix-socket /dev/lxd/sock x/1.0/config/user.INSTELLAR_INSTALLATION_ENDPOINT)"
  token="$(curl -s --unix-socket /dev/lxd/sock x/1.0/config/user.INSTELLAR_BOT_TOKEN)"
  code="$(curl -s -o /dev/null -w "%{http_code}" "${endpoint}" -H "Authorization: Bearer ${token}" -H 'Content-Type: application/json; charset=utf-8')"

  if [[ "$code" == "200" ]]; then
    echo "----- Fetching ${endpoint} -----"

    variables="$(curl -s "${endpoint}" -H "Authorization: Bearer ${token}" -H 'Content-Type: application/json; charset=utf-8' | jq '.data.attributes.variables')"
  else
    echo "----- Fetching from backup -----"

    variables="$(curl -s --unix-socket /dev/lxd/sock x/1.0/config/user.INSTELLAR_INSTALLATION_DATA | base64 -d | jq '.data.attributes.variables')"
  fi
}

manager="$(curl -s --unix-socket /dev/lxd/sock x/1.0/config/user.managed_by)"
export HOSTNAME="$(echo $HOSTNAME)"

if [ "$manager" = "uplink" ]
then
  endpoint="$(curl -s --unix-socket /dev/lxd/sock x/1.0/config/user.install_variables_endpoint)"

  echo "----- Fetching ${endpoint} -----"

  variables="$(curl -s "${endpoint}" -H 'Content-Type: application/json; charset=utf-8' | jq '.data.attributes.variables')"
else
  fetch_from_instellar_or_fallback
fi

while read -rd $'' line
do
  export "$line"
done < <(jq -r <<<"$variables" \
           'to_entries|map("\(.key)=\(.value)\u0000")[]')