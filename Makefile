start-minikube:
	# Istioを使用するために必要な最低限のスペック
	minikube config set cpus 4
	minikube config set memory 16384
	# ノードの構築
	minikube delete
	minikube start --driver=hyperkit --mount=true --mount-string="${HOME}/projects/hiroki-it/microservices-backend:/data"
	# イングレスの有効化
	# minikube addons enable ingress
	# メトリクスの有効化
	minikube addons enable metrics-server
	# dockerクライアントの向き先の変更
	minikube docker-env
	# 手動で実行 
	# eval $(minikube -p minikube docker-env)

kubectl-proxy:
	kubectl proxy --address=0.0.0.0 --accept-hosts='.*' 

apply-k8s:
	skaffold run --force --no-prune=false --cache-artifacts=false

apply-k8s-with-pf:
	skaffold run --force --no-prune=false --cache-artifacts=false --port-forward

apply-istio:
	istioctl operator init
	istioctl install -y -f ./istio/install/operator.yml
	kubectl apply -f ./istio/apply -R
	istioctl verify-install

ISTIO_VERSION=1.12
apply-istio-dashboard:
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_VERSION}/samples/addons/jaeger.yaml
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_VERSION}/samples/addons/kiali.yaml
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_VERSION}/samples/addons/prometheus.yaml

destroy-istio:
	istioctl x uninstall --purge -y

# 同時に，make kubectl-proxy を実行しておくこと．
# @see https://github.com/fortio/fortio#command-line-arguments
ISTIO_LB_IP=$(shell kubectl get service/istio-ingressgateway --namespace=istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
load-test-account:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/account/
load-test-customer:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/customers/
load-test-order:
	docker run fortio/fortio load -c 1 -n 100 http://${ISTIO_LB_IP}/orders/
