#!/usr/bin/env bash
#ddev-generated
# Shared helpers for the ddev-oxid commands. Sourced, not executed.

OXID_ROOT="${OXID_ROOT:-/var/www/html/htdocs}"

# Minimum PHP version per OXID compilation (major.minor). Only the lower bound is
# listed; composer still checks the upper bound. Unknown versions return nothing
# and are offered without a PHP check.
oxid_min_php() {
  case "$1" in
    7.5) echo "8.3" ;;
    7.2|7.3|7.4) echo "8.2" ;;
    7.1) echo "8.1" ;;
    7.0) echo "8.0" ;;
    6.5) echo "7.4" ;;
    6.*) echo "7.1" ;;
  esac
}

# True if the running PHP satisfies the minimum PHP of an OXID major.minor (or it is unknown)
oxid_php_ok() {
  local min
  min=$(oxid_min_php "$1")
  [ -z "$min" ] || php -r 'exit(version_compare(PHP_VERSION, $argv[1], ">=") ? 0 : 1);' "$min"
}

# Random password for generated admin users
oxid_random_password() {
  tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16
}

# Installed OXID major version (6 or 7); empty if not installed
oxid_major() {
  local v
  v=$(composer show -d "$OXID_ROOT" oxid-esales/oxideshop-ce --format=json 2>/dev/null \
    | php -r '$j=json_decode(stream_get_contents(STDIN),true); echo ltrim($j["versions"][0] ?? "", "v");')
  echo "${v%%.*}"
}

oxid_require_install() {
  [ -f "$OXID_ROOT/vendor/bin/oe-console" ] || { echo "Keine OXID-Installation in htdocs gefunden (ddev install-oxid)."; exit 1; }
}

# True if oe-console knows the given command in this OXID version
oxid_has_cmd() {
  (cd "$OXID_ROOT" && ./vendor/bin/oe-console list --raw 2>/dev/null | awk '{print $1}' | grep -qx "$1")
}

# Run an oe-console command or explain that this OXID version does not have it
oxid_console_or_explain() {
  local cmd="$1"; shift
  oxid_require_install
  if ! oxid_has_cmd "$cmd"; then
    echo "Der Befehl ${cmd} existiert in OXID $(oxid_major).x nicht."
    return 2
  fi
  (cd "$OXID_ROOT" && ./vendor/bin/oe-console "$cmd" "$@")
}

oxid_default_theme() {
  if [ "$(oxid_major)" = "6" ]; then echo "flow"; else echo "apex"; fi
}

oxid_clear_tmp() {
  [ -d "$OXID_ROOT/source/tmp" ] && find "$OXID_ROOT/source/tmp" -mindepth 1 ! -name .htaccess -delete
  return 0
}

# Manual shop setup for OXID 6.x (there is no oe:setup:shop before 7.0).
# Args: shop_url [demo:y|n]
oxid_setup_legacy() {
  local shop_url="$1" demo="$2"
  cd "$OXID_ROOT"
  mkdir -p source/tmp
  cp source/config.inc.php.dist source/config.inc.php
  sed -i \
    -e "s#<dbHost>#db#" -e "s#<dbName>#db#" -e "s#<dbUser>#db#" -e "s#<dbPwd>#db#" \
    -e "s#<sShopURL>#${shop_url}/#" \
    -e "s#<sShopDir>#${OXID_ROOT}/source/#" \
    -e "s#<sCompileDir>#${OXID_ROOT}/source/tmp/#" \
    source/config.inc.php
  mysql -h db -u db -pdb db < source/Setup/Sql/database_schema.sql
  if [ "$demo" = "y" ]; then
    # demodata.sql replaces initial_data.sql; the installer only copies the media files
    mysql -h db -u db -pdb db < vendor/oxid-esales/oxideshop-demodata-ce/src/demodata.sql
    ./vendor/bin/oe-eshop-demodata_install
  else
    mysql -h db -u db -pdb db < source/Setup/Sql/initial_data.sql
  fi
  ./vendor/bin/oe-eshop-db_migrate migrations:migrate
  ./vendor/bin/oe-eshop-db_views_generate
}

# Set the admin credentials directly in the DB (OXID 6 without oe:admin:create-user)
oxid_admin_sql() {
  local email="$1" password="$2" hash
  hash=$(php -r 'echo password_hash($argv[1], PASSWORD_BCRYPT);' "$password")
  mysql -h db -u db -pdb db -e "UPDATE oxuser SET OXUSERNAME='${email//\'/}', OXPASSWORD='${hash}', OXPASSSALT='' WHERE OXRIGHTS='malladmin' LIMIT 1;"
}
