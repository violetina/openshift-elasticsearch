include Makefile-yaml
PROJECT=openshift-solr
WD=/tmp
REPO_URI=https://github.com/violetina/openshift-elasticsearch.git
GIT_NAME=openshift-elasticsearch
APP_NAME=elasticsearch
TAG=${ENV}
#compose.yaml  data-persistentvolumeclaim.yaml  solr-deploymentconfig.yaml  solr-imagestream.yaml  solr-service.yaml
#slaafje=`oc get pods | grep slaafje | cut -d ' ' -f 1 `
podname=`oc get pods | grep solr | cut -d ' ' -f 1 |grep -v deploy`
#set_policy=set_policy ha-fed ".*" '{"ha-mode":"all"}' --priority 1 --apply-to queues
TOKEN=`oc whoami -t`
path_to_oc=`which oc`
oc_registry=docker-registry-default.35.156.140.167.xip.io
.ONESHELL:
SHELL = /bin/bash
.PHONY:	all
check-env:
ifndef ENV
  $(error ENV is undefined)
endif
OC_PROJECT=solr-${ENV}
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
	oc login 10.55.10.79:8443
	oc project "${OC_PROJECT}" ||  oc new-project "${OC_PROJECT}"
        oc adm policy add-scc-to-user privileged -nelasticsearch -z default
	#openshift.io/sa.scc.uid-range: 8983/1
	#oc edit namespace solr
	docker login -p "${TOKEN}" -u unused ${oc_registry}
#	oc get imagestream  "${OC_PROJECT}" || oc create imagestream  "${OC_PROJECT}"

clone:
	cd /tmp && git clone  --single-branch -b ${BRANCH} "${REPO_URI}" 
deploy:
	oc create -f build/openshift/createStorageSolr_pv.yaml

clean:
	rm -rf /tmp/${GIT_NAME}
podshell:
	oc exec -ti `oc get pods | grep es-master | cut -d ' ' -f 1 |grep -v deplo`  bash
all:	clean checkTools login  clone  push deploy clean

