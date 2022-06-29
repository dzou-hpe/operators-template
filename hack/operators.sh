# create a new operator project
if [[ -z $1 ]]; then
  echo "specify operator name"
  exit 1
fi

OPERATOR_NAME="${1}"

echo "Create github actions"
mkdir -p .github/workflows
cp hack/ci.template.yaml .github/workflows/temp.yaml
sed "s/@REPLACEME@/${OPERATOR_NAME}/g" .github/workflows/temp.yaml > .github/workflows/${OPERATOR_NAME}-operator.yaml
rm .github/workflows/temp.yaml

echo "create with kubebuilder"
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/
GIT_REPO=$(cat .git/config  | grep url | awk -F'@' '{print $2}' | awk -F':' '{print $2}' | awk -F'.' '{print $1}')
cwd=$(pwd)
mkdir -p operators/${OPERATOR_NAME}
cd operators/${OPERATOR_NAME}
kubebuilder init --domain my.domain --repo github.com/${GIT_REPO}

cp Makefile Makefile.tmp
sed  -e "s/controller:latest/${OPERATOR_NAME}-operator:latest/g"  \
    Makefile.tmp > Makefile
rm Makefile.tmp
cat ${cwd}/hack/makefile.patch >> Makefile

cd ${cwd}
