#!/bin/bash
set -e
cd /tmp
# python for ansible
curl https://pyenv.run | /bin/bash

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

source ~/.bashrc

pyenv install 3.12.7

pyenv local 3.12.7
# kube
git clone https://github.com/kubernetes-sigs/kubespray.git

cd kubespray

cp -rfp inventory/sample inventory/k8s_cluster

cp ../extra.yml inventory/k8s_cluster/group_vars/k8s_cluster/addons.yml

python3 -m venv .venv

source .venv/bin/activate

pip install --upgrade pip

pip install -r requirements.txt

chmod -R 777 inventory/k8s_cluster

cp ../hosts.ini inventory/k8s_cluster/inventory.ini
# start ansible-playbook
ansible-playbook -u ubuntu -i inventory/k8s_cluster/inventory.ini -e "serial=1" -b cluster.yml

cd ..

deactivate

rm -rf kubespray/

cd /home/ubuntu
# kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

source <(kubectl completion bash)

echo "source <(kubectl completion bash)" >> ~/.bashrc

source .bashrc

mkdir .kube

ssh -o StrictHostKeyChecking=no ubuntu@$1 "sudo cp /etc/kubernetes/admin.conf /tmp/config ; sudo chown ubuntu:ubuntu /tmp/config"

scp -o StrictHostKeyChecking=no ubuntu@$1:/tmp/config .kube/config

sudo chown ubuntu:ubuntu .kube/config

val=$(kubectl get nodes | grep control-plane | cut -d' ' -f1 | tail -n +1)
for server in $val; do
  kubectl taint nodes "$server" node-role.kubernetes.io/control-plane:NoSchedule-
done
# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

helm completion bash > ~/.helm_completion.sh

echo "source ~/.helm_completion.sh" >> ~/.bashrc

source ~/.bashrc