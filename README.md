# Ackee k8s Elasticsearch image + GCS backup plugin

## Available versions / tags:
- 5.1.1

## Prerequisities

You will need:
* A cluster with 1GB * number of containers you want to run of free memory on your cluster (tested with no big load with 2048M)
* A bucket + credentials for storing snapshots (see "Creating a bucket"@https://www.elastic.co/guide/en/elasticsearch/plugins/master/repository-gcs-usage.html)

## Before you start

    cd k8s

Edit `CLUSTER_NAME` to set name of your cluster. Do this at least in `es-client.yml`, `es-master.yml` and `es-data.yml`.

For larger cluster set Java memory limits in `ES_JAVA_OPTS`. I have no general tip yet.

Add credentials json file (see prerequisities) to `GS_CRED_FILE_CONTENT` env variable. Just pick the file, run `base64 file.json` and set the variable to the output of the command. You have to do this in every yml file.

If you know what are you doing and don't want to back up the service, set `GS_NO_BACKUP` to `yes` (again, in every yml file).

## Howto

Create minimal service:

    kubectl create -f es-discovery-svc.yaml --namespace whatever
    kubectl create -f es-svc.yaml --namespace whatever

You can edit this file if you want to save money for the loadbalancer

    kubectl create -f es-master.yaml --namespace whatever
Wait for the container to come up

    kubectl create -f es-client.yaml --namespace whatever
Wait for the container to come up

    kubectl create -f es-data.yaml --namespace whatever
Wait for the container to come up

Get service IP:

    E_IP=`kubectl get svc elasticsearch --namespace whatever|grep ^elasticsearch|awk '{print $3}'`

And verify the installation:

    curl http://$E_IP:9200/_cluster/health?pretty

Then scale the service:

    kubectl scale deployment es-master --replicas 2 --namespace whatever
    kubectl scale deployment es-client --replicas 2 --namespace whatever
    kubectl scale deployment es-data --replicas 3 --namespace whatever

You can upload testing index:

    curl -v -XPOST 'http://$E_IP:9200/shakespeare/_bulk?pretty' --data-binary @shakespeare.json

And check it out:

    curl http://elastic:changeme@$E_IP:9200/_cat/indices

DON'T FORGET to change the default password (changeme)!!!
    curl -XPUT -u elastic '$E_IP:9200/_xpack/security/user/elastic/_password' -d '{
       "password" : "elasticpassword"
    }'

## Backing up

Backups will be done using cronjob specified in `k8s/gcs-backup.yml`. This is not supported yet (needs k8s 1.5.0+)

### Create GCS repository (Requires valid credentials, see "Before you start"

    curl -s -XPUT http://$E_IP:9200/_snapshot/my_gcs_repository_on_compute_engine?pretty -d '{
      "type": "gcs",
      "settings": {
        "bucket": "BUCKET_NAME_IN_GOOGLE_STORAGE",
        "service_account": "gs.json"
      }
    }'

### Create the snapshot

    curl -s -XPUT http://$E_IP:9200/_snapshot/my_gcs_repository_on_compute_engine/SNAPSHOT_NAME?wait_for_completion=true
