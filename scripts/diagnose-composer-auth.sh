#!/usr/bin/env bash
set -euo pipefail

label="${1:-diagnostic}"

echo "== ${label}: runtime =="
command -v php || true
php --version | head -n 1 || true
command -v composer || true
composer --version || true

echo "== ${label}: token presence =="
for name in GITHUB_TOKEN GH_CONTEXT_TOKEN GH_SECRET_TOKEN COMPOSER_AUTH; do
  value="${!name-}"
  if [ -n "${value}" ]; then
    length="$(printf '%s' "${value}" | wc -c | tr -d ' ')"
    case "${value}" in
      *-*) has_hyphen=yes ;;
      *) has_hyphen=no ;;
    esac
    echo "${name}=set length=${length} has_hyphen=${has_hyphen}"
  else
    echo "${name}=unset"
  fi
done

echo "== ${label}: composer auth sources =="
composer_home="$(composer config --global home 2>/dev/null || true)"
if [ -n "${composer_home}" ]; then
  echo "composer_home=${composer_home}"
  if [ -f "${composer_home}/auth.json" ]; then
    echo "global_auth_json=present"
    python3 - "${composer_home}/auth.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as handle:
    data = json.load(handle)

for section, value in sorted(data.items()):
    if isinstance(value, dict):
        keys = ",".join(sorted(value.keys()))
        print(f"auth_section={section} keys={keys}")
    else:
        print(f"auth_section={section} type={type(value).__name__}")
PY
  else
    echo "global_auth_json=absent"
  fi
fi

if [ -f auth.json ]; then
  echo "project_auth_json=present"
else
  echo "project_auth_json=absent"
fi

if git config --global --get github.accesstoken >/dev/null 2>&1; then
  echo "git_config_github_accesstoken=present"
else
  echo "git_config_github_accesstoken=absent"
fi

echo "== ${label}: GitHub API rate limit =="
curl -sSI https://api.github.com/rate_limit | tr -d '\r' | grep -i '^x-ratelimit-' || true
