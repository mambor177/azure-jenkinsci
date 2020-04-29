DEPLOYMENT_FILE := jenkins-deployment.yaml

AZ_SUBSCRIPTION := b3185911-c383-4d02-8fab-ef0ae53f9312
CONTAINER_REGISTRY_FQDN := acr177.azurecr.io
CONTAINER_REGISTRY := acr177

RSG_NAME := rsg_jenkinsci
CLUSTER_NAME := aks_jenkins

JENKINS_NAMSPACE := jenkins

# Jenkins Master Image Name
IMAGE_NAME := jenkins-on-kubernetes
# Jenkins Master tag version to build and deploy
JENKINS_TAG := v1.2

# Temp file to Search/Replace against during dpeloyment
TEMPFILE := jenkins-deployment-current.yaml

blank:
	echo "Nothing to see here folks!"

## Terraform
init: azlogin
	cd terraform/; \
	rm -rf .terraform; \
	terraform init; \
	
plan: azlogin
	cd terraform/; \
	rm -rf .terraform; \
	terraform init; \
	terraform plan;

apply: azlogin
	cd terraform/; \
	rm -rf .terraform; \
	terraform init; \
	terraform apply;

# Docker/Image Preperation
image:
	#docker build -t $(IMAGE_NAME):$(JENKINS_TAG) ./docker/
	docker build -t $(CONTAINER_REGISTRY_FQDN)/$(IMAGE_NAME):$(JENKINS_TAG) ./docker/

push:
	az acr login --name $(CONTAINER_REGISTRY)
	#docker tag $(IMAGE_NAME):$(JENKINS_TAG) $(CONTAINER_REGISTRY_FQDN)/$(IMAGE_NAME):$(JENKINS_TAG)
	docker push $(CONTAINER_REGISTRY_FQDN)/$(IMAGE_NAME):$(JENKINS_TAG)


## Kbernetes Setup Commands
#namespace: akslogin
namespace:
	kubectl create namespace $(JENKINS_NAMSPACE)

#rbac: akslogin namespace # Need to add logic in akslogin and namespace to validate subscription and namespace existence.
rbac: 
	kubectl -n $(JENKINS_NAMSPACE) apply -f ./k8s/jenkins-admin-rbac.yaml

#service: akslogin namespace # Need to add logic in akslogin and namespace to validate subscription and namespace existence.
service: 
	kubectl -n $(JENKINS_NAMSPACE) apply -f ./k8s/jenkins-service-internal.yaml
	kubectl -n $(JENKINS_NAMSPACE) apply -f ./k8s/jenkins-service-lb.yaml

#deployment: akslogin namespace # Need to add logic in akslogin and namespace to validate subscription and namespace existence.
deployment: 
	cp ./k8s/$(DEPLOYMENT_FILE) ./k8s/$(TEMPFILE)
	cd ./k8s; sed -i '' 's/--JENKINS_TAG--/$(JENKINS_TAG)/g' $(TEMPFILE)
	cd ./k8s; sed -i '' 's/--CONTAINER_REGISTRY_FQDN--/$(CONTAINER_REGISTRY_FQDN)/g' $(TEMPFILE)
	kubectl -n $(JENKINS_NAMSPACE) apply -f ./k8s/$(TEMPFILE)
	rm ./k8s/$(TEMPFILE)

## Misc.
current-context:
	kubectl config current-context

azlogin:
	az login
	az account set --subscription $(AZ_SUBSCRIPTION)

akslogin: azlogin
	# Set default namesace: #kubectl config set-context $(CLUSTER_NAME) --current --namespace=$(JENKINS_NAMSPACE)
	az aks get-credentials --resource-group $(RSG_NAME) --name $(CLUSTER_NAME)
	az aks install-cli
	kubectl config set-context $(CLUSTER_NAME)

dashboard: #login
	#az aks get-credentials --resource-group $(RSG_NAME) --name $(CLUSTER_NAME)
	## Need logic to check for this role before reapply.
	#kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
	az aks browse --resource-group $(RSG_NAME) --name $(CLUSTER_NAME)

debug:
	# this is a debugging image that contains tools i've found useful.  (telnet/nslookup/etc.)
	kubectl run -i --tty --rm debug --image=praqma/network-multitool --restart=Never -n $(JENKINS_NAMSPACE) -- /bin/bash

jenkins:
	# open a chrome tab into jenkins console
	## needs to be added to local hosts file for resolution.
	/usr/bin/open -a "/Applications/Google Chrome.app" 'https://jenkins-lb.jenkins.svc.cluster.local'
