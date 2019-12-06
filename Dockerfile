FROM hashicorp/terraform:latest

RUN apk add --update git bash openssh jq && \
    mkdir /terraform

ADD src /terraform

ENTRYPOINT ["terraform"]