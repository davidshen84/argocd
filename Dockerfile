ARG ARGOCD_VERSION=2.4.11 \
    SOPS_VERSION=3.7.3 \
    HELM_SECRETS_VERSION=4.0.0

FROM argoproj/argocd:v${ARGOCD_VERSION}

ARG SOPS_VERSION \
    HELM_SECRETS_VERSION

LABEL maintainer="David Shen" \
    SOPS=${SOPS_VERSION} \
    HELM=${HELM_SECRETS_VERSION} \
    AZ=latest

USER root

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    curl \
    age \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 /usr/local/bin/sops
RUN chmod 0755 /usr/local/bin/sops

USER argocd

ENV HELM_PLUGINS=/home/argocd/.local/share/helm/plugins/

RUN helm plugin install https://github.com/jkroepke/helm-secrets --version v${HELM_SECRETS_VERSION}

