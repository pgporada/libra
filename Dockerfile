FROM gliderlabs/alpine:3.3

# variables for building
ARG TRAEFIK_VERSION="1.0.0-beta.247"
ENV TRAEFIK_VERSION=$TRAEFIK_VERSION

ARG DUMB_INIT_VERSION="1.0.1"
ENV DUMB_INIT_VERSION=$DUMB_INIT_VERSION

ARG CONSUL_TEMPLATE_VERSION=0.12.1
ENV CONSUL_TEMPLATE_VERSION=$CONSUL_TEMPLATE_VERSION

# install dependencies
ADD https://github.com/containous/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_linux-amd64 /usr/bin/traefik
ADD https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 /usr/bin/dumb-init
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /tmp/consul-template.zip

RUN chmod +x /usr/bin/traefik && \
    chmod +x /usr/bin/dumb-init && \
    unzip -d /usr/bin /tmp/consul-template.zip && \
    chmod +x /usr/bin/consul-template && \
    apk add --no-cache bash ca-certificates

# add configuration
COPY traefik.toml /etc/traefik/traefik.toml

# add consul-template templates and targets
COPY rules.toml.tmpl /etc/consul-template/templates/rules.toml.tmpl
COPY config.d /etc/consul-template/config.d

# add the run scripts
COPY libra.sh /usr/bin/libra

EXPOSE 80

ENTRYPOINT ["libra"]
