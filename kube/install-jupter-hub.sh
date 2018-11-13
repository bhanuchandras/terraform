helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
  --namespace $NAMESPACE  \
  --version 0.7.0 \
  --values config.yaml

kubectl config set-context $(kubectl config current-context) --namespace ${NAMESPACE:-jhub}

