#!/bin/sh
  # TRUTH-MD startup script for Pterodactyl — wraps the relay launcher.
  # Sets correct port, cleans stale relay cache, starts with optimal heap.

  detect_ram_mb() {
      if [ -f /proc/meminfo ]; then
          awk '/MemTotal/ { printf "%d", $2 / 1024 }' /proc/meminfo
      elif command -v sysctl >/dev/null 2>&1; then
          sysctl -n hw.memsize | awk '{ printf "%d", $1 / 1024 / 1024 }'
      else
          echo 512
      fi
  }

  TOTAL_RAM_MB=$(detect_ram_mb)
  if [ "$TOTAL_RAM_MB" -le 512 ]; then
      MAX_OLD=$(( TOTAL_RAM_MB * 70 / 100 ))
  else
      MAX_OLD=$(( TOTAL_RAM_MB * 75 / 100 ))
  fi
  [ "$MAX_OLD" -lt 100  ] && MAX_OLD=100
  [ "$MAX_OLD" -gt 8192 ] && MAX_OLD=8192
  echo "『 TRUTH-MD 』 RAM: ${TOTAL_RAM_MB}MB  →  heap limit: ${MAX_OLD}MB"

  # Map Pterodactyl's SERVER_PORT to PORT so the bot health server uses it
  if [ -n "$SERVER_PORT" ]; then
      export PORT="$SERVER_PORT"
  fi
  echo "『 TRUTH-MD 』 Using port: ${PORT:-8080}"

  # Clean stale relay cache to prevent disk exhaustion
  RELAY_DIR="/tmp/truth-md-bot"
  if [ -d "$RELAY_DIR" ]; then
      DIR_COUNT=$(find "$RELAY_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
      if [ "$DIR_COUNT" -gt 2 ]; then
          echo "『 TRUTH-MD 』 Cleaning old relay cache ($DIR_COUNT entries, keeping 2)..."
          find "$RELAY_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%T+ %p\n' 2>/dev/null \
              | sort | head -n $(( DIR_COUNT - 2 )) | awk '{print $2}' \
              | xargs rm -rf 2>/dev/null || true
      fi
  fi

  exec node \
      --max-old-space-size="$MAX_OLD" \
      --optimize-for-size \
      --gc-interval=100 \
      --expose-gc \
      index.js
  