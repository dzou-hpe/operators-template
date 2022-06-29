# create a new operator project
if [[ -z $1 ]]; then
  echo "specify operator name"
  exit 1
fi

OPERATOR_NAME="${1}"

if [ -d operators/"${OPERATOR_NAME}" ];then
  echo "Operator: ${OPERATOR_NAME} exists"
  exit 1
fi

if [ ! -f config ];then
  read -p "Opeartor Domin:" domain
  echo "${domain}" > config

  echo "create k3d cluster"
  K3D_CLUSTER_NAME="operators"
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  k3d cluster delete ${K3D_CLUSTER_NAME} || true
  k3d cluster create ${K3D_CLUSTER_NAME} \
    -a 2 \
    --agents-memory 1g \
    --servers-memory 1g \
    --no-lb \
    --wait \
    --k3s-arg "--node-name=worker-1"@agent:0 \
    --k3s-arg "--node-name=worker-2"@agent:1 \
    --k3s-arg "--node-name=master"@server:0
  k3d kubeconfig merge ${K3D_CLUSTER_NAME} --kubeconfig-switch-context
  echo
  kubectl get nodes
else 
  domain="$(cat config)"
fi
echo "Create github actions"
mkdir -p .github/workflows
cp hack/ci.template.yaml .github/workflows/temp.yaml
sed "s/@REPLACEME@/${OPERATOR_NAME}/g" .github/workflows/temp.yaml > .github/workflows/"${OPERATOR_NAME}"-operator.yaml
rm .github/workflows/temp.yaml

echo "create with kubebuilder"
curl -s -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/
GIT_REPO=$(cat .git/config  | grep url | awk -F'@' '{print $2}' | awk -F':' '{print $2}' | awk -F'.' '{print $1}')
cwd=$(pwd)
mkdir -p operators/"${OPERATOR_NAME}"
cd operators/"${OPERATOR_NAME}" || exit
kubebuilder init --domain  "${domain}"  --repo github.com/"${GIT_REPO}"/"${OPERATOR_NAME}"

cp Makefile Makefile.tmp
sed  -e "s/controller:latest/${OPERATOR_NAME}-operator:latest/g"  \
    Makefile.tmp > Makefile
rm Makefile.tmp
cat "${cwd}"/hack/makefile.patch >> Makefile

cd "${cwd}" || exit
