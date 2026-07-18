#!/bin/bash

#Deleta o cluster atual, caso exista, para garantir uma instalação limpa
minikube delete --all=true --purge=true

#Inicia o Minikube com as configurações especificadas, neste caso estou usando:
# --driver=docker: Usa o driver Docker para criar o cluster.
# --cpus=4: Aloca 4 CPUs para o cluster.
# --memory=8192: Aloca 8GB de memória para o cluster.
# --cni=flannel: Usa o Flannel como plugin de rede para o cluster.
# -n=2: Cria um cluster com 2 nós.
minikube start --driver=docker --cpus=4 --memory=8192 --cni=flannel -n=2

#Habilita os addons necessários para o cluster, neste caso:
# storage-provisioner: Habilita o provisionador de armazenamento dinâmico, permitindo que os volumes sejam criados automaticamente quando necessário.
minikube addons enable storage-provisioner

# default-storageclass: Define a classe de armazenamento padrão para o cluster, facilitando a criação de volumes persistentes sem especificar uma classe.
minikube addons enable default-storageclass

# metrics-server: Habilita o servidor de métricas, que coleta e fornece métricas de recursos do cluster, como uso de CPU e memória, essencial para monitoramento e escalonamento automático de aplicações.
minikube addons enable metrics-server


# kubevirt: Habilita o addon do KubeVirt, que permite a execução de máquinas virtuais dentro do cluster Kubernetes, facilitando a integração de workloads tradicionais com aplicações nativas em nuvem.
minikube addons enable kubevirt




# Instalação do Containerized Data Importer (CDI) para facilitar a importação de imagens de máquinas virtuais para o cluster KubeVirt.
# O CDI é uma ferramenta que simplifica o processo de importação de dados para o Kubernetes, especialmente útil para importar imagens de máquinas virtuais em formatos como QCOW2 ou RAW, permitindo que essas imagens sejam usadas como fontes para criar máquinas virtuais no KubeVirt.
export TAG=$(curl -s https://api.github.com/repos/kubevirt/containerized-data-importer/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$TAG/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$TAG/cdi-cr.yaml

# Aguarda um momento para garantir que o CDI esteja totalmente implantado antes de prosseguir com a importação da imagem.
sleep 120

# Realiza o port-forwarding para o serviço do CDI Upload Proxy, permitindo que a ferramenta virtctl se comunique com o serviço de upload do CDI para importar a imagem da máquina virtual.
kubectl port-forward -n cdi svc/cdi-uploadproxy 8443:443


###Sob análise da execução. atualmente esse trecho está demorando muito tempo para concluir a importação da imagem, o que pode ser devido ao tamanho da imagem ou à velocidade de upload. Recomendo monitorar o processo e verificar os logs do CDI para identificar possíveis gargalos ou erros durante a importação.
# ./virtctl image-upload pvc fedora-pvc \
#   --size=10Gi \
#   --image-path=/path/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2 \
#   --default-instancetype=n1.medium \
#   --default-preference=fedora \
#   --access-mode=ReadWriteOnce \
#   --uploadproxy-url=http://127.0.0.1:8443 \
#   --insecure


# Acessar o dashboard do Minikube para monitorar o cluster e verificar o status dos recursos implantados, como os pods, serviços e volumes persistentes.
minikube dashboard


# Faz a instalação do plugin Headlamp, que é uma interface gráfica para gerenciamento de clusters Kubernetes, facilitando a visualização e administração dos recursos do cluster.
# Primeiro, criamos uma conta de serviço chamada headlamp-admin, que terá as permissões necessárias para acessar e gerenciar os recursos do cluster através do Headlamp.
kubectl create serviceaccount headlamp-admin

# Em seguida, criamos um ClusterRoleBinding chamado headlamp-admin-binding, que vincula a conta de serviço headlamp-admin ao ClusterRole cluster-admin, concedendo a ela permissões administrativas completas sobre o cluster, permitindo que o Headlamp tenha acesso total para gerenciar os recursos do Kubernetes.
kubectl create clusterrolebinding headlamp-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=default:headlamp-admin

# Arquivo dash.yaml para implantar o Headlamp no cluster Kubernetes, configurando-o para usar a conta de serviço headlamp-admin e garantindo que ele tenha acesso aos plugins necessários para a integração com o KubeVirt.
dash.yaml
---------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: headlamp
  labels:
    app: headlamp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: headlamp
  template:
    metadata:
      labels:
        app: headlamp
    spec:
      serviceAccountName: headlamp-admin # 1. Adicionado: Diz ao Pod para usar as permissões de admin que criamos
      initContainers:
        - name: headlamp-kubevirt
          image: ghcr.io/naval-group/headlamp-kubevirt:latest
          command: ['/bin/sh', '-c']
          args:
            - 'cp -r /plugins/kubevirt /headlamp-plugins/'
          volumeMounts:
            - name: headlamp-plugins
              mountPath: /headlamp-plugins
      containers:
        - name: headlamp
          image: ghcr.io/headlamp-k8s/headlamp:latest
          ports:
            - containerPort: 4466
              name: http
          args:
            - '-in-cluster' # 2. Adicionado: Informa ao backend que ele está rodando dentro do K8s
            - '-plugins-dir=/headlamp/plugins'
          volumeMounts:
            - name: headlamp-plugins
              mountPath: /headlamp/plugins
      volumes:
        - name: headlamp-plugins
          emptyDir: {}


# Após criar o arquivo dash.yaml com a configuração do Headlamp, aplicamos essa configuração ao cluster Kubernetes usando o comando kubectl apply, que cria os recursos necessários para implantar o Headlamp no cluster.
kubectl apply -f dash.yaml

# Aguarda um momento para garantir que o Headlamp esteja totalmente implantado e em execução antes de tentar acessá-lo, permitindo que os pods sejam iniciados e estejam prontos para aceitar conexões.
sleep 120

# Depois de implantar o Headlamp, usamos o comando kubectl port-forward para criar um túnel local que permite acessar a interface do Headlamp através do navegador, redirecionando a porta 4466 do Pod do Headlamp para a porta 4466 no localhost, facilitando o acesso à interface gráfica do Headlamp para gerenciar o cluster Kubernetes.
kubectl port-forward deploy/headlamp 4466:4466

# Para acessar o Headlamp, é necessário gerar um token de autenticação para a conta de serviço headlamp-admin, que será usado para fazer login na interface do Headlamp e garantir que o usuário tenha as permissões necessárias para gerenciar os recursos do cluster Kubernetes.
kubectl create token headlamp-admin --duration=24h

# Uma vez que o token é gerado, ele pode ser usado para fazer login na interface do Headlamp, acessível através do endereço
http://127.0.0.1:4466/c/main/token


# Para resolver problema de disco, tive que adicionar os addons abaixo

# O addon volumesnapshots é necessário para habilitar o suporte a snapshots de volumes persistentes no cluster Kubernetes, permitindo que os usuários criem e gerenciem snapshots de seus volumes para backup e recuperação de dados.
minikube addons enable volumesnapshots

# O addon csi-hostpath-driver é um driver de armazenamento CSI (Container Storage Interface) que permite o uso de volumes persistentes baseados em hostPath no cluster Kubernetes, facilitando a criação e gerenciamento de volumes persistentes para aplicações que precisam de armazenamento local.
minikube addons enable csi-hostpath-driver

# O arquivo fedora.yaml é um exemplo de configuração para criar uma máquina virtual (VirtualMachineInstance) usando o KubeVirt, que é uma extensão do Kubernetes para executar máquinas virtuais dentro do cluster. Este arquivo define uma máquina virtual chamada "testvmi-nocloud" com recursos específicos, como memória, dispositivos de disco e volumes, incluindo um disco de container com a imagem do Fedora Cloud e um disco vazio para armazenamento adicional. Além disso, ele configura um disco de cloud-init para fornecer dados de inicialização personalizados, como a configuração de senha para o usuário "fedora". Este tipo de configuração é útil para criar e gerenciar máquinas virtuais em um ambiente Kubernetes usando o KubeVirt.
fedora.yaml
-----------
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: fedora-vm07
  namespace: vm
spec:
  runStrategy: Always
  template:
    metadata: {}
    spec:
      domain:
        devices:
          disks:
            - name: fedora-vm07-boot-volume
              disk:
                bus: virtio
            - name: cloudinitdisk
              disk:
                bus: virtio
          interfaces:
            - name: default
              masquerade: {}
        resources:
          requests:
            memory: 2Gi
        cpu:
          cores: 2
      networks:
        - name: default
          pod: {}
      volumes:
        - name: fedora-vm07-boot-volume
          dataVolume:
            name: fedora-vm07-boot-volume
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #cloud-config
  dataVolumeTemplates:
    - metadata:
        name: fedora-vm07-boot-volume
      spec:
        source:
          registry:
            url: docker://quay.io/containerdisks/fedora:latest
        storage:
          accessModes:
            - ReadWriteMany
          resources:
            requests:
              storage: 30Gi
          storageClassName: csi-hostpath-sc


















=========




apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: fedora-vm05
  namespace: vm
spec:
  runStrategy: Always
  template:
    metadata: {}
    spec:
      domain:
        devices:
          disks:
            - name: fedora-vm05-boot-volume
              disk:
                bus: virtio
            - name: cloudinitdisk
              disk:
                bus: virtio
          interfaces:
            - name: default
              masquerade: {}
        resources:
          requests:
            memory: 2Gi
        cpu:
          cores: 2
      networks:
        - name: default
          pod: {}
      volumes:
        - name: fedora-vm05-boot-volume
          dataVolume:
            name: fedora-vm05-boot-volume
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #cloud-config
  dataVolumeTemplates:
    - metadata:
        name: fedora-vm04-boot-volume
      spec:
        source:
          registry:
            url: docker://quay.io/containerdisks/fedora:43
        storage:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 30Gi
          storageClassName: csi-hostpath-sc



Add prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring