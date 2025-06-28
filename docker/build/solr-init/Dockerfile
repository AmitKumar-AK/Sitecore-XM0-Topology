# escape=`

ARG PARENT_IMAGE
ARG SXA_IMAGE

FROM ${SXA_IMAGE} as sxa
FROM ${PARENT_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=sxa .\module\solr\ C:\data\