#!/bin/sh

cat <<EOF > /usr/share/nginx/html/config.js
window.APP_CONFIG = {
  PULL_INTERVAL_ALERTS: ${PULL_INTERVAL_ALERTS}
  SOC_HOST: ${SOC_HOST}
};
EOF