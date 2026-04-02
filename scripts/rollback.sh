
#!/usr/bin/env bash
set -euo pipefail

NS=${1:?"Usage: rollback.sh <namespace> <app> <color>"}
APP=${2:?"Usage: rollback.sh <namespace> <app> <color>"}
COLOR=${3:?"Usage: rollback.sh <namespace> <app> <color>"}

kubectl -n "${NS}" patch svc "${APP}" -p '{"spec":{"selector":{"app":"'"${APP}"'","color":"'"${COLOR}"'"}}}'
echo "Rolled back ${APP} to color=${COLOR}"
