#!/usr/bin/env bash
set -euo pipefail

CAM_NAME="${CAM_NAME:-cam1}"
RTSP_URL="${RTSP_URL:-rtsp://user:pass@192.168.1.10:554/stream}"
OUT_DIR="${OUT_DIR:-/var/cameras/${CAM_NAME}}"

mkdir -p "${OUT_DIR}"
mkdir -p "${OUT_DIR}/logs"

# Папки по дате
DATE_DIR="${OUT_DIR}/$(date +%Y/%m/%d)"
mkdir -p "${DATE_DIR}"

exec /usr/bin/ffmpeg \
  -hide_banner \
  -loglevel info \
  -rtsp_transport tcp \
  -stimeout 10000000 \
  -rw_timeout 10000000 \
  -fflags +genpts+discardcorrupt \
  -use_wallclock_as_timestamps 1 \
  -i "${RTSP_URL}" \
  -map 0:v:0 \
  -map 0:a? \
  -c copy \
  -f segment \
  -segment_time 60 \
  -reset_timestamps 1 \
  -strftime 1 \
  -segment_atclocktime 1 \
  "${OUT_DIR}/%Y/%m/%d/${CAM_NAME}_%Y-%m-%d_%H-%M-%S.ts"

