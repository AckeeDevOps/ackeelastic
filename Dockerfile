FROM quay.io/pires/docker-elasticsearch-kubernetes:5.1.1

RUN /elasticsearch/bin/elasticsearch-plugin install analysis-icu
RUN /elasticsearch/bin/elasticsearch-plugin install repository-gcs <<< y
