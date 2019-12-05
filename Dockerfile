FROM golang:alpine

ENV TERRAFORM_VERSION "0.12.16"
ENV TF_DEV=true
ENV TF_RELEASE=true

RUN apk add --update git bash openssh jq && \
    mkdir /terraform

ENV TF_DEV=true
ENV TF_RELEASE=true

WORKDIR $GOPATH/src/github.com/hashicorp/terraform
RUN git clone https://github.com/hashicorp/terraform.git ./ && \
    git checkout v${TERRAFORM_VERSION} && \
    /bin/bash scripts/build.sh

ADD src /terraform

WORKDIR $GOPATH
ENTRYPOINT ["terraform"]