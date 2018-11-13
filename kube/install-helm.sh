gcloud beta container clusters get-credentials bhanu-chandra --region asia-east1 --project cloudjupyter-bhanu
kubectl get all
EMAIL=bhanuchandra.sabbavarapu@gmail.com

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$EMAIL

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
helm version
helm init --upgrade --service-account tiller
kubectl patch deployment tiller-deploy --namespace=kube-system --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'

