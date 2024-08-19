ARG ALPINE_VERSION=3.20
ARG TRAEFIK_VERSION
ARG UID=1000
ARG GID=1000

####################################################################################################
## Final image
####################################################################################################
FROM --platform=${TARGETPLATFORM} alpine:${ALPINE_VERSION}

ARG TARGETARCH
ARG TRAEFIK_VERSION
ARG UID
ARG GID

RUN apk add --no-cache \
    ca-certificates \
    tzdata

RUN wget --quiet -O /tmp/traefik.tar.gz "https://github.com/traefik/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_v${TRAEFIK_VERSION}_linux_${TARGETARCH}.tar.gz" && \
    tar xzvf /tmp/traefik.tar.gz -C /usr/local/bin traefik && \
    rm -f /tmp/traefik.tar.gz && \
    chmod +x /usr/local/bin/traefik
COPY --chmod=0755 entrypoint.sh /

RUN addgroup -S -g ${GID} traefik && \
    adduser -S -H -D -G traefik -u ${UID} -g "" -s /sbin/nologin traefik && \
    mkdir -p /etc/traefik /var/lib/traefik/acme /var/log/traefik && \
    chown -R traefik:traefik /var/log/traefik && \
    chown -R traefik:traefik /var/lib/traefik && \
    chmod 700 /var/lib/traefik/acme

USER traefik
ENTRYPOINT ["/entrypoint.sh"]
CMD ["traefik"]
EXPOSE 80
STOPSIGNAL SIGTERM

LABEL org.opencontainers.image.title="Traefik"
LABEL org.opencontainers.image.description="A modern reverse-proxy"
LABEL org.opencontainers.image.version="v${TRAEFIK_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/traefik/traefik.git"
LABEL org.opencontainers.image.licenses="MIT"