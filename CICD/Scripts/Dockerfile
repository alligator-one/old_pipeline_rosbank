ARG NEXUS_HOST="test_host"
FROM ${NEXUS_HOST}/general/ansible:2.7
 
LABEL IMAGE_TAG="ansible-2.7-python-jira-python-jenkins"
 
ARG NEXUS_HOST
ARG PIP_REPO="https://${NEXUS_HOST}/repository/pypi-org-proxy/simple"
ARG PIP_DEFAULT_ARGS="--disable-pip-version-check --no-cache-dir --timeout 120 --trusted-host ${NEXUS_HOST} -i ${PIP_REPO}"
ARG PIP_PACKAGES="jira==2.0.0 python-jenkins==1.6.0 gitpython==3.1.20"
 
COPY ./etc /tmp/etc
 
RUN rm -rf /etc/yum.repos.d/* \
    && mkdir -p /etc/pki/entitlement &&  cp /tmp/etc/pki/entitlement/* /etc/pki/entitlement \
    && mkdir -p /etc/pki/ca-trust/source/anchors && cp /tmp/etc/pki/ca-trust/source/anchors/* /etc/pki/ca-trust/source/anchors \
    && mkdir -p /etc/rhsm/ca && cp /tmp/etc/rhsm/ca/* /etc/rhsm/ca \
    && mkdir -p /etc/yum.repos.d/ && cp /tmp/etc/yum.repos.d/* /etc/yum.repos.d/ \
    && rm -rf /tmp/* \
    && update-ca-trust extract
 
RUN echo $PIP_DEFAULT_ARGS
 
RUN yum install -y \
        python3 \
        python3-pip \
    && pip3 install --upgrade ${PIP_DEFAULT_ARGS} pip \
    && yum clean all && rm -rf /var/cache/yum \
    && pip3 install ${PIP_DEFAULT_ARGS} ${PIP_PACKAGES}