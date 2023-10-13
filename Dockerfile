FROM alpine:edge
LABEL "author" "Weaverize <dev@weaverize.com>"

WORKDIR /root
RUN apk add --update postgresql-client mariadb-client git openssh-client
COPY script.sh ./
CMD ./script.sh