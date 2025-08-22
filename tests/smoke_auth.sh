#!/usr/bin/env bash
# Smoke test for credentials stored in macOS Keychain and basic API reachability
#
# Checks:
#  - GitHub:  service 'github-mcp',    account 'token'    -> GET https://api.github.com/user
#  - Atlassian: service 'atlassian-mcp', account 'api-token' -> GET https://$ATLASSIAN_DOMAIN/rest/api/3/myself (requires ATLASSIAN_EMAIL, ATLASSIAN_DOMAIN)
#  - Bitbucket: service 'bitbucket-mcp', account 'app-password'    -> GET https://api.bitbucket.org/2.0/user (requires ATLASSIAN_BITBUCKET_USERNAME)
#
# Output: PASS/FAIL for each provider with helpful troubleshooting hints. Never prints secret values.
#
# Usage:
#   scripts/smoke_auth.sh
#
set -euo pipefail

red()   { printf "\033[31m%s\033[0m" "$*"; }
green() { printf "\033[32m%s\033[0m" "$*"; }
yellow(){ printf "\033[33m%s\033[0m" "$*"; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

keychain_pw() {
  # Prints the password to stdout if found, otherwise returns non-zero
  local service="$1"; local account="$2"
  security find-generic-password -s "$service" -a "$account" -w 2>/dev/null
}

note_locked_keychain() {
  echo "  hint: If your keychain is locked, unlock it: security unlock-keychain" >&2
}

print_header() {
  echo ""
  echo "== $1 =="
}

pass_line() { echo "$(green PASS) $1"; }
fail_line() { echo "$(red FAIL) $1"; }
warn_line() { echo "$(yellow WARN) $1"; }

check_github() {
  print_header "GitHub"
  local service="github-mcp" account="token"
  local token
  if ! token=$(keychain_pw "$service" "$account"); then
    fail_line "Keychain item missing: service '$service', account '$account'"
    echo "  fix: Add with Keychain Access or run secure prompt:" >&2
    echo "       ( unset HISTFILE; stty -echo; printf 'Enter GitHub PAT: '; read PW; stty echo; printf '\n'; \"security\" add-generic-password -s github-mcp -a token -w \"$PW\"; unset PW )" >&2
    note_locked_keychain
    return 1
  fi
  if [[ -z "$token" ]]; then
    fail_line "Keychain item present but empty value (service '$service', account '$account')"
    return 1
  fi
  if ! have_cmd curl; then
    warn_line "curl not found; skipping API reachability test"
    return 0
  fi
  # Minimal profile check
  local code
  code=$(curl -sS -o /dev/null -w '%{http_code}' \
    -H "Authorization: token $token" \
    https://api.github.com/user || echo "000")
  if [[ "$code" =~ ^2 ]]; then
    pass_line "API reachable (GET /user -> $code)"
  else
    fail_line "API auth failed (GET /user -> $code)"
    echo "  hint: Ensure PAT scopes are sufficient (repo, read:org, read:user, user:email) and not expired." >&2
  fi
}

check_atlassian() {
  print_header "Atlassian (Jira Cloud)"
  local service="atlassian-mcp" account="api-token"
  local token
  if ! token=$(keychain_pw "$service" "$account"); then
    fail_line "Keychain item missing: service '$service', account '$account'"
    echo "  fix: Add with Keychain Access (service atlassian-mcp, account api-token)." >&2
    note_locked_keychain
    return 1
  fi
  if [[ -z "$token" ]]; then
    fail_line "Keychain item present but empty value (service '$service', account '$account')"
    return 1
  fi
  local domain="${ATLASSIAN_DOMAIN:-guttmacher.atlassian.net}" email="${ATLASSIAN_EMAIL:-}"
  if [[ -z "${ATLASSIAN_DOMAIN:-}" ]]; then
    warn_line "ATLASSIAN_DOMAIN was not set; defaulting to '$domain'"
  fi
  if [[ -z "$email" ]]; then
    # Derive email: prefer git config user.email, else user@org based on domain
    if command -v git >/dev/null 2>&1; then
      email="$(git config --get user.email 2>/dev/null || true)"
    fi
    if [[ -z "$email" ]]; then
      email="${USER}@${domain//.atlassian.net/.org}"
    fi
    warn_line "ATLASSIAN_EMAIL unset; using derived '$email'"
  fi
  if ! have_cmd curl; then
    warn_line "curl not found; skipping API reachability test"
    return 0
  fi
  local code
  code=$(curl -sS -o /dev/null -w '%{http_code}' -u "$email:$token" \
    "https://$domain/rest/api/3/myself" || echo "000")
  if [[ "$code" =~ ^2 ]]; then
    pass_line "API reachable (GET /rest/api/3/myself -> $code)"
  else
    fail_line "API auth failed (GET /rest/api/3/myself -> $code)"
    echo "  hint: Verify ATLASSIAN_DOMAIN, ATLASSIAN_EMAIL, and API token are correct and active." >&2
  fi
}

check_bitbucket() {
  print_header "Bitbucket"
  local service="bitbucket-mcp" account="app-password"
  local app_pass
  if ! app_pass=$(keychain_pw "$service" "$account"); then
    fail_line "Keychain item missing: service '$service', account '$account'"
    echo "  fix: Add with Keychain Access (service bitbucket-mcp, account app-password)." >&2
    note_locked_keychain
    return 1
  fi
  if [[ -z "$app_pass" ]]; then
    fail_line "Keychain item present but empty value (service '$service', account '$account')"
    return 1
  fi
  local user="${ATLASSIAN_BITBUCKET_USERNAME:-}"
  if [[ -z "$user" ]]; then
    local default_user="" git_email=""
    if command -v git >/dev/null 2>&1; then
      git_email="$(git config --get user.email 2>/dev/null || true)"
    fi
    if [[ -n "$git_email" ]]; then
      default_user="${git_email%@*}"
    else
      default_user="$USER"
    fi
    if [[ -t 0 && -t 2 ]]; then
      printf "Bitbucket username [%s]: " "$default_user" >&2
      read -r input_username
      user="${input_username:-$default_user}"
      warn_line "Using Bitbucket username '$user' for this check"
    else
      user="$default_user"
      warn_line "ATLASSIAN_BITBUCKET_USERNAME unset; non-interactive shell. Using derived '$user'"
    fi
  fi
  if ! have_cmd curl; then
    warn_line "curl not found; skipping API reachability test"
    return 0
  fi
  local code
  code=$(curl -sS -o /dev/null -w '%{http_code}' -u "$user:$app_pass" \
    https://api.bitbucket.org/2.0/user || echo "000")
  if [[ "$code" =~ ^2 ]]; then
    pass_line "API reachable (GET /2.0/user -> $code)"
  else
    fail_line "API auth failed (GET /2.0/user -> $code)"
    echo "  hint: Ensure username and app password are correct and have necessary scopes." >&2
  fi
}

main() {
  echo "Auth smoke test (macOS Keychain)"
  echo "This checks required keychain items and performs minimal API calls with curl."
  local rc=0
  check_github   || rc=1
  check_atlassian|| rc=1
  check_bitbucket|| rc=1
  echo ""
  if [[ $rc -eq 0 ]]; then
    echo "All checks $(green PASSED)"
  else
    echo "Some checks $(red FAILED). See messages above."
  fi
  exit $rc
}

main "$@"
