#!/usr/bin/env bash
set -euo pipefail

: "${CAM_NAME:?CAM_NAME is required}"
: "${RTSP_URL:?RTSP_URL is required}"
: "${OUT_DIR:?OUT_DIR is required}"

mkdir -p "${OUT_DIR}"
mkdir -p "${OUT_DIR}/logs"
mkdir -p "${OUT_DIR}/$(date +%Y/%m/%d)"

exec /usr/bin/ffmpeg \
  -hide_banner \
  -loglevel info \
  -rtsp_transport tcp \
  -rw_timeout 10000000 \
  -fflags +genpts+discardcorrupt \
  -use_wallclock_as_timestamps 1 \
  -i "${RTSP_URL}" \
  -map 0:v:0 \
  -map 0:a? \
  -c copy \
  -f segment \
  -segment_time 60 \
  -segment_atclocktime 1 \
  -reset_timestamps 1 \
  -strftime 1 \
  "${OUT_DIR}/%Y/%m/%d/${CAM_NAME}_%Y-%m-%d_%H-%M-%S.ts"