FROM python:3.9.0-slim

# 環境変数
ARG AWS_PROFILE
ENV AWS_PROFILE $AWS_PROFILE

# Telepresence/kubectlの導入
RUN apt update \
&& apt install -y curl sudo unzip iptables libfuse-dev software-properties-common \
&& curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | bash \
&& apt install -y --no-install-recommends telepresence \
&& curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl \
&& chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl \
&& curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip

# Docker/AWS CLIの導入
# AWSおよびKubernetesへ接続するためのシークレット
RUN curl https://get.docker.com | sh \ 
&& unzip awscliv2.zip \
&& aws/install \
&& rm -fr aws awscliv2.zip \
&& mkdir ~/.kube && mkdir ~/.aws

# cloudアクセスおよびkubectl実行環境設定
COPY .kube/config /root/.kube/config
COPY .aws/config /root/.aws/config
COPY .aws/credentials /root/.aws/credentials

ENTRYPOINT ["/bin/bash"]