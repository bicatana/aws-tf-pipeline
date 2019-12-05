FROM hashicorp/terraform:latest

ADD src /terraform

ENTRYPOINT ["terraform"]