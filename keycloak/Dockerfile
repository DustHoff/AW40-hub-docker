# syntax=docker/dockerfile:1.7.0
FROM quay.io/keycloak/keycloak:20.0
ENV KC_HEALTH_ENABLED true

# Set the working directory
WORKDIR /opt/keycloak

ADD keycloak-config.sh /opt/keycloak/bin/
# Build Keycloak
RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

# Run the script as the entrypoint
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

HEALTHCHECK --start-period=30s --start-interval=1s --interval=30s --timeout=5s --retries=5 \
  CMD curl --head -fsS http://localhost:8080/health/ready || exit 1
