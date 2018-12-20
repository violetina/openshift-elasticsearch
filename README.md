# AVO-elasticsearch-cluster with matchbox plugin
Elasticsearch (6.4.2) cluster on top of Kubernetes made easy.


## Setup
### Openshift project setup
running the make file will setup the project and install the templates to deploy the cluster and applicatio,
```make all

```
### templates  setup
- login to the openshift cluster
- import the templates:
  - for each env add a es cluster and indexer app select from project and fill in the params
