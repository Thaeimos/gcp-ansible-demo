FROM ubuntu:23.10

# Variables
ARG TF_HOME=/home/gcp-ansible-demo
ARG TF_VERSION="1.7.4"

## APT to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## Preesed tzdata, update package index, upgrade packages and install needed software
RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select Madrid" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata

# Common packages
RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg apt-utils python3 dnsutils git bsdmainutils csvkit shellcheck pip vim jq net-tools bash-completion yq python3.11-venv gnupg2 software-properties-common lsb-release gnupg wget unzip

# Google Cloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-cli

# Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
RUN kubectl version --client

# Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
RUN echo 'source <(helm completion bash)' >> /root/.bashrc

# Add bash-completion
RUN echo 'source /usr/share/bash-completion/bash_completion' >> /root/.bashrc
RUN echo 'source <(kubectl completion bash)' >> /root/.bashrc

WORKDIR ${TF_HOME}

# Ansible
RUN apt-get update && apt install -y ansible

# Terraform
RUN wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_$(dpkg --print-architecture).zip
RUN unzip terraform_${TF_VERSION}_linux_$(dpkg --print-architecture).zip
RUN mv terraform /usr/local/bin/
RUN echo 'complete -C /usr/bin/terraform terraform' >> /root/.bashrc

# Gcloud init at login
RUN echo 'gcloud init --console-only --skip-diagnostics' >> /root/.bashrc

# Use default Gcloud service account if no secret present. Otherwise, use secret for defined service account
RUN echo 'FILE="/home/gcp-prod-cons/secrets/service-account-credentials.json"\n\
if [ -f "$FILE" ]; then\n\
    echo "$FILE exists."\n\
    gcloud auth activate-service-account --key-file=$FILE\n\
    export GOOGLE_APPLICATION_CREDENTIALS="$FILE"\n\
else \n\
    echo "$FILE does not exist."\n\
    gcloud auth application-default login --no-launch-browser\n\
fi\n\
' >> /root/.bashrc

ENTRYPOINT ["/bin/bash"]