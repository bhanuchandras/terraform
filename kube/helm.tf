variable "helm_version" {
  default = "v2.11.1"
}

variable "acme_email" {}

variable "acme_url" {
  default = "https://acme-v01.api.letsencrypt.org/directory"
}

provider "helm" {
  kubernetes {
    host                   = "${google_container_cluster.primary.endpoint}"
    token                  = "${data.google_client_config.current.access_token}"
    client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
  }
}

resource "helm_repository" "jupyterhub" {
    name = "jupyterhub"
    url  = "https://jupyterhub.github.io/helm-chart/"
}

resource "null_resource" "tiller" {
  provisioner "local-exec" {
    command = <<EOT
	gcloud beta container clusters get-credentials bhanu-chandra --region asia-east1 --project cloudjupyter-bhanu
	kubectl get all
	EMAIL=bhanuchandra.sabbavarapu@gmail.com
	kubectl create clusterrolebinding cluster-admin-binding \
	  --clusterrole=cluster-admin \
	  --user=$EMAIL
	curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
	kubectl --namespace kube-system create serviceaccount tiller
	kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
	helm init --service-account tiller --wait
	helm version
	helm init --upgrade --service-account tiller
	kubectl patch deployment tiller-deploy --namespace=kube-system --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'
	sleep 1m
EOT
  }
  depends_on = [
   "google_container_cluster.primary",
  ]
}

resource "helm_release" "jhub" {
  name = "jhub"
  namespace = "jhub"
  chart = "jupyterhub/jupyterhub"
  version = "0.7.0"
  values = [
    "${file("config.yaml")}"
  ]
  depends_on = [
     "null_resource.tiller",
     "helm_repository.jupyterhub",
  ]
}
