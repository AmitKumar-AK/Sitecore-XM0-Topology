# escape=`

ARG PARENT_IMAGE
ARG HEADLESS_SERVICES_IMAGE
ARG SPE_IMAGE

FROM ${HEADLESS_SERVICES_IMAGE} AS headless_services
FROM ${SPE_IMAGE} as spe
FROM ${PARENT_IMAGE}

# spe module
COPY --from=spe C:\module\db C:\resources\spe

# Copy and init the JSS / Headless Services Module
COPY --from=headless_services C:\module\db C:\resources\jss