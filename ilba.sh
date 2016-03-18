#!/usr/bin/dumb-init /bin/bash
set -e
# set the DEBUG env variable to turn on debugging
[[ -n "$DEBUG" ]] && set -x

CONSUL_LOGLEVEL=${CONSUL_LOGLEVEL:-info}
CONSUL_CONNECT=${CONSUL_CONNECT:-consul.service.consul:8500}

function usage {
    cat <<USAGE
ilba                start a single app proxy for Consul services

Configure using the following environment variables:

ilba vars:
  SERVICE           the service to launch

  CIRCUIT_BREAKER   a Traefik circuit breaker expression
                    (default "NetworkErrorRatio() > 0.5")

consul vars:
  CONSUL_LOGLEVEL   Set the consul-template log level
                    (default info)

  CONSUL_CONNECT    URI fro the Consul agent
                    (default not set)

  CONSUL_SSL        Connect to Consul using SSL
                    (default not set)

  CONSUL_SSL_VERIFY Verify Consul SSL connection
                    (default true)

  CONSUL_TOKEN      Consul API token
                    (default not set)
USAGE
}

function launch {
    if [[ ! -n "${SERVICE}" ]]; then
        usage
        echo "Please specify an service to balance."
        exit 1
    fi

    ctargs=
    [[ -n "${CONSUL_CONNECT}" ]] && ctargs="${ctargs} -consul=${CONSUL_CONNECT}"
    [[ -n "${CONSUL_SSL}" ]] && ctargs="${ctargs} -ssl"
    [[ -n "${CONSUL_SSL_VERIFY}" ]] && ctargs="${ctargs} -ssl-verify=${CONSUL_SSL_VERIFY}"
    [[ -n "${CONSUL_TOKEN}" ]] && ctargs="${ctargs} -token=${CONSUL_TOKEN}"

    # create an empty rules file so Traefik will start
    touch /etc/traefik/rules.toml

    # start traefik in background
    traefik --configFile=/etc/traefik/traefik.toml &

    # start consul-template as the owner of the process
    exec consul-template -log-level ${CONSUL_LOGLEVEL} \
                         -config /etc/consul-template/config.d \
                         ${ctargs}
}

launch
