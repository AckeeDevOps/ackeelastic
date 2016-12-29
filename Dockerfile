FROM: quay.io/pires/docker-elasticsearch-kubernetes:latest

RUN /elasticsearch/bin/elasticsearch-plugin install analysis-icu
RUN /elasticsearch/bin/elasticsearch-plugin install repository-gcs <<< y
