FROM terraform:latest

ADD src /terraform

ENTRYPOINT ["terraform"]