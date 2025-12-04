#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
  local message=$1
  local color=${2:-NC}
  echo -e "${!color}${message}${NC}"
}

check_env_variable() {
  local name=$1
  local description=$2
  local value=$(eval "echo \$$name")
  
  if [ -n "$value" ]; then
    log "✓ $description: $value" "GREEN"
    return 0
  else
    log "✗ $description ($name) not set" "RED"
    return 1
  fi
}

check_port_open() {
  local host=$1
  local port=$2
  local name=$3
  
  if command -v nc &> /dev/null; then
    nc -z -w 3 "$host" "$port" 2>/dev/null
    if [ $? -eq 0 ]; then
      log "✓ $name port $port is open" "GREEN"
      return 0
    else
      log "✗ $name port $port is closed" "RED"
      return 1
    fi
  else
    log "⚠ nc command not found, skipping port check" "YELLOW"
    return 0
  fi
}

make_request() {
  local url=$1
  local timeout=${2:-5}
  
  if command -v curl &> /dev/null; then
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout $timeout "$url" 2>/dev/null)
    if [ ! -z "$http_code" ]; then
      echo "$http_code"
    else
      echo "000"
    fi
  else
    echo "000"
  fi
}

check_backend_health() {
  log "\n=== Backend Health Check ===" "CYAN"
  
  backend_url="${NEXT_PUBLIC_BACKEND_URL:-http://localhost:3000}"
  
  log "Checking backend at: $backend_url"
  
  http_code=$(make_request "$backend_url/health")
  
  if [ "$http_code" = "200" ] || [ "$http_code" = "404" ]; then
    log "✓ Backend is responding ($http_code)" "GREEN"
    return 0
  elif [ "$http_code" = "000" ]; then
    log "✗ Backend unreachable" "RED"
    return 1
  else
    log "✗ Backend returned error status: $http_code" "RED"
    return 1
  fi
}

check_cors_configuration() {
  log "\n=== CORS Configuration Check ===" "CYAN"
  
  if [ -z "$FRONTEND_URL" ]; then
    log "✗ FRONTEND_URL not set - CORS will fail" "RED"
    return 1
  fi
  
  log "Frontend URL: $FRONTEND_URL"
  backend_url="${NEXT_PUBLIC_BACKEND_URL:-http://localhost:3000}"
  log "Backend URL: $backend_url"
  
  # Extract protocol and host
  frontend_origin=$(echo "$FRONTEND_URL" | sed 's|^\(.*://[^/]*\).*|\1|')
  log "Allowed CORS origin: $frontend_origin" "YELLOW"
  
  return 0
}

check_database_connection() {
  log "\n=== Database Connection Check ===" "CYAN"
  
  if [ -z "$DATABASE_URL" ]; then
    log "✗ DATABASE_URL not set" "RED"
    return 1
  fi
  
  # Parse PostgreSQL URL (postgresql://user:password@host:port/database)
  # Extract host and port
  db_url="${DATABASE_URL#postgresql://}"
  db_url="${db_url#*@}"
  db_host="${db_url%%:*}"
  db_port="${db_url#*:}"
  db_port="${db_port%%/*}"
  db_port=${db_port:-5432}
  
  log "Database: $db_host:$db_port"
  
  check_port_open "$db_host" "$db_port" "PostgreSQL"
}

check_redis_connection() {
  log "\n=== Redis Connection Check ===" "CYAN"
  
  if [ -z "$REDIS_URL" ]; then
    log "✓ REDIS_URL not set - MockRedis will be used (development mode)" "YELLOW"
    return 0
  fi
  
  # Parse Redis URL (redis://[password@]host:port)
  redis_url="${REDIS_URL#redis://}"
  redis_url="${redis_url#*@}"
  redis_host="${redis_url%%:*}"
  redis_port="${redis_url#*:}"
  
  log "Redis: $redis_host:$redis_port"
  
  if check_port_open "$redis_host" "$redis_port" "Redis"; then
    return 0
  else
    log "⚠ Redis not available - MockRedis will be used" "YELLOW"
    return 0
  fi
}

run_all_checks() {
  log "\n╔════════════════════════════════════════════════╗" "BLUE"
  log "║      POZMIXAL Health Check Script              ║" "BLUE"
  log "╚════════════════════════════════════════════════╝" "BLUE"
  
  # Load .env file if it exists
  if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
  fi
  
  log "\n=== Environment Variables ===" "CYAN"
  check_env_variable "FRONTEND_URL" "Frontend URL"
  check_env_variable "NEXT_PUBLIC_BACKEND_URL" "Backend URL"
  check_env_variable "DATABASE_URL" "Database URL"
  check_env_variable "JWT_SECRET" "JWT Secret"
  
  # Run all checks and count results
  check_backend_health
  backend_status=$?
  
  check_cors_configuration
  cors_status=$?
  
  check_database_connection
  db_status=$?
  
  check_redis_connection
  redis_status=$?
  
  # Count passed checks
  passed=$(( (backend_status == 0) + (cors_status == 0) + (db_status == 0) + (redis_status == 0) ))
  total=4
  
  log "\n=== Summary ===" "CYAN"
  log "Passed: $passed/$total" "$([ $passed -eq $total ] && echo GREEN || echo YELLOW)"
  
  if [ $passed -eq $total ]; then
    log "\n✓ All checks passed! Your Pozmixal setup is ready." "GREEN"
    exit 0
  else
    log "\n✗ Some checks failed. See details above." "RED"
    log "\nFor help, check TROUBLESHOOTING.md" "YELLOW"
    exit 1
  fi
}

run_all_checks
