FROM bitnami/minideb:jessie-amd64

RUN install_packages apt-transport-https cron curl zip lsb-release unzip

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/4.0 main" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN install_packages mongodb-org-shell mongodb-org-tools

RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl --insecure https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN install_packages google-cloud-sdk

RUN mkdir -p /backup /restore

COPY migrate_backup_gs.sh restore.sh run.sh tmp_mongo_user.js /

RUN chmod +x /run.sh

ENTRYPOINT ["/bin/bash", "/run.sh"]
