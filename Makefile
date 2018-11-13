include Makefile-yaml
PROJECT=elasticsearch-${ENV}
WD=/tmp
REPO_URI=https://github.com/violetina/openshift-elasticsearch.git
GIT_NAME=openshift-elasticsearch
APP_NAME=elasticsearch
TAG=${ENV}
#compose.yaml  data-persistentvolumeclaim.yaml  solr-deploymentconfig.yaml  solr-imagestream.yaml  solr-service.yaml
#slaafje=`oc get pods | grep slaafje | cut -d ' ' -f 1 `
podname=`oc get pods | grep es-ingest | cut -d ' ' -f 1 |grep -v deploy`
#set_policy=set_policy ha-fed ".*" '{"ha-mode":"all"}' --priority 1 --apply-to queues
TOKEN=`oc whoami -t`
path_to_oc=`which oc`
oc_registry=docker-registry-default.apps.do-prd-okp-m0.do.viaa.be
.ONESHELL:
SHELL = /bin/bash
.PHONY:	all
check-env:
ifndef ENV
  $(error ENV is undefined)
endif
OC_PROJECT=${PROJECT}
ifndef BRANCH
  $(error BRANCH is undefined)
endif

commit:
	git add .
	git commit -a
	git push
checkTools:
	if [ -x "${path_to_executable}" ]; then  echo "OC tools found here: ${path_to_executable}"; else echo please install the oc tools: https://github.com/openshiftorigin/releases/tag/v3.9.0; fi; uname && netstat | grep docker| grep -e CONNECTED  1> /dev/null || echo docker not running or not using linux
login:	check-env
	oc login do-prd-okp-m0.do.viaa.be:8443
	oc project "${OC_PROJECT}" ||  oc new-project "${OC_PROJECT}"
	oc adm policy add-scc-to-user privileged -n${OC_PROJECT} -z default
	#openshift.io/sa.scc.uid-range: 8983/1
	#oc edit namespace solr
	docker login -p "${TOKEN}" -u unused ${oc_registry}
#	oc get imagestream  "${OC_PROJECT}" || oc create imagestream  "${OC_PROJECT}"

clone:
	cd /tmp && git clone  --single-branch -b ${BRANCH} "${REPO_URI}" 
deploy:
	oc  create -f build/openshift/es-discovery-svc.yaml
	oc  create -f build/openshift/es-svc.yaml 
	oc  create -f build/openshift/es-master-svc.yaml 
	oc  create -f build/openshift/es-master-stateful.yaml 
	oc  create -f build/openshift/es-ingest-svc.yaml 
	oc  create -f build/openshift/es-ingest.yaml 
	oc  create -f build/openshift/es-data-svc.yaml 
	oc  create -f build/openshift/es-data-stateful.yaml 
	oc create -f build/openshift/kibana-svc.yaml
delete:
	oc delete project ${OC_PROJECT}
clean:
	rm -rf /tmp/${GIT_NAME}
podshell:
	oc exec -ti `oc get pods | grep es-ingest | cut -d ' ' -f 1 |grep -v deploy|head -n1`  bash
all:	clean commit  login  clone  clean

