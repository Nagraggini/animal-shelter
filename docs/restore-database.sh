
#!/bin/bash

set -euo pipefail
umask 077

# A script a docs mappában van, a projekt gyökere annak szülőmappája.
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

API_KEY_FILE="$HOME/.config/render/api-key"
API="https://api.render.com/v1"

POSTGRES_NAME="Postgre"
POSTGRES_DATABASE_NAME="database"
POSTGRES_VERSION="16"
POSTGRES_REGION="frankfurt"
POSTGRES_PLAN="free"

REUSE_EXISTING=false

trap 'unset RENDER_API_KEY DB_PASS PGPASSWORD CONNECTION_INFO EXTERNAL_DB_URL' EXIT

echo "======================================"
echo " Render PostgreSQL Auto Restore"
echo "======================================"
echo

# 1. Szükséges programok ellenőrzése.
for cmd in curl jq python3 psql; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Missing program: $cmd"
        exit 1
    fi
done

# 2. API-kulcs beolvasása.
if [ ! -f "$API_KEY_FILE" ]; then
    echo "ERROR: Render API key not found!"
    exit 1
fi

RENDER_API_KEY="$(tr -d '\r\n' < "$API_KEY_FILE")"

if [ -z "$RENDER_API_KEY" ]; then
    echo "ERROR: Empty API key."
    exit 1
fi

# Segédfüggvény: a Postgre szolgáltatás keresése.
find_postgres() {
    local response

    response=$(curl --fail-with-body --silent --show-error \
        --get "$API/postgres" \
        --data-urlencode "name=$POSTGRES_NAME" \
        --data-urlencode "limit=100" \
        -H "Authorization: Bearer $RENDER_API_KEY")

    jq -r --arg name "$POSTGRES_NAME" \
        '.[] | select(.postgres.name == $name) | .postgres.id' \
        <<< "$response"
}

# Az animal-shelter web service megkeresése.
find_web_service() {
    local response

    response=$(curl --fail-with-body --silent --show-error \
        --get "$API/services" \
        --data-urlencode "name=$WEB_SERVICE_NAME" \
        --data-urlencode "type=web_service" \
        --data-urlencode "ownerId=$OWNER_ID" \
        --data-urlencode "limit=100" \
        -H "Authorization: Bearer $RENDER_API_KEY")

    jq -r \
        --arg name "$WEB_SERVICE_NAME" \
        --arg owner "$OWNER_ID" \
        '.[] |
         select(
             .service.name == $name and
             .service.type == "web_service" and
             .service.ownerId == $owner
         ) |
         .service.id' <<< "$response"
}


# Egyetlen környezeti változó biztonságos frissítése.
update_web_env_var() {
    local key="$1"
    local value="$2"
    local body
    local http_status

    body=$(jq -n --arg value "$value" '{value: $value}')

    if ! http_status=$(curl --silent --show-error \
        --output /dev/null \
        --write-out '%{http_code}' \
        --request PUT \
        "$API/services/$WEB_SERVICE_ID/env-vars/$key" \
        -H "Authorization: Bearer $RENDER_API_KEY" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data-binary @- <<< "$body"); then

        echo "ERROR: Could not update $key."
        return 1
    fi

    if [[ ! "$http_status" =~ ^2[0-9][0-9]$ ]]; then
        echo "ERROR: Updating $key failed (HTTP $http_status)."
        return 1
    fi

    echo "$key updated successfully."
}

# 3. Meglévő Postgre adatbázis keresése.
echo "Searching for Postgre database..."

mapfile -t POSTGRES_IDS < <(find_postgres)

if [ "${#POSTGRES_IDS[@]}" -gt 1 ]; then
    echo "ERROR: Multiple databases named $POSTGRES_NAME found."
    echo "No database was deleted."
    exit 1
fi

OWNER_ID=""
POSTGRES_ID=""

# 4. Meglévő adatbázis kezelése.
if [ "${#POSTGRES_IDS[@]}" -eq 1 ]; then

    POSTGRES_ID="${POSTGRES_IDS[0]}"

    POSTGRES_DETAILS=$(curl --fail-with-body --silent --show-error \
        "$API/postgres/$POSTGRES_ID" \
        -H "Authorization: Bearer $RENDER_API_KEY")

    FOUND_NAME=$(jq -r '.name // empty' <<< "$POSTGRES_DETAILS")
    OWNER_ID=$(jq -er '.owner.id' <<< "$POSTGRES_DETAILS")
    OLD_DATABASE_NAME=$(jq -r '.databaseName // empty' <<< "$POSTGRES_DETAILS")

    if [ "$FOUND_NAME" != "$POSTGRES_NAME" ]; then
        echo "ERROR: Name verification failed."
        echo "No database was deleted."
        exit 1
    fi

    echo
    echo "Existing PostgreSQL database found!"
    echo "--------------------------------------"
    echo "Service name:  $FOUND_NAME"
    echo "Database name: $OLD_DATABASE_NAME"
    echo "Postgres ID:   $POSTGRES_ID"
    echo "--------------------------------------"
    echo
    echo "What would you like to do?"
    echo
    echo "[r] Reuse existing database"
    echo "[y] Delete and create a new database"
    echo "[e] Exit without changes"
    echo

    read -r -p "Your choice [r/y/e]: " CONFIRM

    case "$CONFIRM" in

        r|R)
            echo
            echo "Using existing PostgreSQL database."
            REUSE_EXISTING=true
            ;;

        y|Y|yes|YES|Yes)
            echo
            echo "WARNING: Deletion is irreversible!"
            echo "All data in this database will be lost."
            echo

            read -r -p "Confirm deletion? [y/N]: " DELETE_CONFIRM

            case "$DELETE_CONFIRM" in

                y|Y|yes|YES|Yes)
                    echo
                    echo "Deleting PostgreSQL database..."

                    curl --fail-with-body --silent --show-error \
                        --request DELETE "$API/postgres/$POSTGRES_ID" \
                        -H "Authorization: Bearer $RENDER_API_KEY" \
                        -H "Accept: application/json" \
                        -o /dev/null

                    echo "Deletion request accepted."
                    echo "Waiting for database deletion..."

                    DELETED=false

                    for attempt in {1..60}; do

                        mapfile -t REMAINING_IDS < <(find_postgres)

                        if [ "${#REMAINING_IDS[@]}" -eq 0 ]; then
                            DELETED=true
                            break
                        fi

                        echo "Database still exists ($attempt/60)"
                        sleep 10
                    done

                    if [ "$DELETED" != true ]; then
                        echo "ERROR: Database deletion timeout."
                        echo "New database was NOT created."
                        exit 1
                    fi

                    echo "Old database deleted successfully!"
                    ;;

                *)
                    echo "Deletion cancelled."
                    echo "No database was modified."
                    exit 0
                    ;;
            esac
            ;;

        e|E)
            echo
            echo "Operation cancelled."
            echo "No database was modified."
            exit 0
            ;;

        *)
            echo
            echo "Invalid choice."
            echo "No database was modified."
            exit 1
            ;;
    esac

else

    echo "Postgre database not found."
    echo "A new database will be created without asking."

fi

# 5. Workspace kiválasztása, ha új adatbázist hozunk létre.
if [[ "$REUSE_EXISTING" != true && -z "$OWNER_ID" ]]; then

    echo
    echo "Retrieving Render workspaces..."

    OWNERS=$(curl --fail-with-body --silent --show-error \
        "$API/owners?limit=100" \
        -H "Authorization: Bearer $RENDER_API_KEY")

    mapfile -t OWNER_ROWS < <(
        jq -r '.[] | [.owner.id, .owner.name] | @tsv' <<< "$OWNERS"
    )

    if [ "${#OWNER_ROWS[@]}" -eq 0 ]; then
        echo "ERROR: No Render workspace found."
        exit 1
    fi

    if [ "${#OWNER_ROWS[@]}" -eq 1 ]; then

        OWNER_ID="${OWNER_ROWS[0]%%$'\t'*}"

    else

        echo "Select your Render workspace:"

        for i in "${!OWNER_ROWS[@]}"; do
            echo "$((i+1)). ${OWNER_ROWS[$i]#*$'\t'}"
        done

        read -r -p "Workspace number: " CHOICE

        if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] ||
            [ "$CHOICE" -lt 1 ] ||
            [ "$CHOICE" -gt "${#OWNER_ROWS[@]}" ]; then
            echo "ERROR: Invalid selection."
            exit 1
        fi

        OWNER_ID="${OWNER_ROWS[$((CHOICE-1))]%%$'\t'*}"

    fi

fi

# 6. Új PostgreSQL létrehozása, ha nem a meglévőt használjuk.
if [[ "$REUSE_EXISTING" != true ]]; then

    echo
    echo "Creating new PostgreSQL database..."
    echo "Service name: $POSTGRES_NAME"
    echo "Database name: $POSTGRES_DATABASE_NAME"

    CREATE_BODY=$(jq -n \
        --arg name "$POSTGRES_NAME" \
        --arg ownerId "$OWNER_ID" \
        --arg databaseName "$POSTGRES_DATABASE_NAME" \
        --arg version "$POSTGRES_VERSION" \
        --arg region "$POSTGRES_REGION" \
        --arg plan "$POSTGRES_PLAN" \
        '{
            name: $name,
            ownerId: $ownerId,
            databaseName: $databaseName,
            plan: $plan,
            region: $region,
            version: $version,
            enableHighAvailability: false,
            enableDiskAutoscaling: false,
            connectionPool: "none"
        }')

    RESPONSE_FILE=$(mktemp)

    if ! HTTP_STATUS=$(curl --silent --show-error \
        --output "$RESPONSE_FILE" \
        --write-out '%{http_code}' \
        --request POST "$API/postgres" \
        -H "Authorization: Bearer $RENDER_API_KEY" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$CREATE_BODY"); then

        echo "ERROR: Could not connect to Render API."
        cat "$RESPONSE_FILE"
        rm -f "$RESPONSE_FILE"
        exit 1
    fi

    if [[ "$HTTP_STATUS" != 2* ]]; then
        echo
        echo "ERROR: Render API returned HTTP $HTTP_STATUS:"
        jq . "$RESPONSE_FILE" 2>/dev/null || cat "$RESPONSE_FILE"
        rm -f "$RESPONSE_FILE"
        exit 1
    fi

    CREATE_RESPONSE=$(cat "$RESPONSE_FILE")
    rm -f "$RESPONSE_FILE"

    POSTGRES_ID=$(jq -er '.id' <<< "$CREATE_RESPONSE")

    echo "New database creation requested!"
    echo "Postgres ID: $POSTGRES_ID"

fi

# 7. Új adatbázis esetén várakozás.
if [[ "$REUSE_EXISTING" != true ]]; then

    echo
    echo "Waiting for PostgreSQL to become available..."

fi

# 8. Adatbázis elérhetőségének ellenőrzése.
AVAILABLE=false

for attempt in {1..60}; do

    POSTGRES_DETAILS=$(curl --fail-with-body --silent --show-error \
        "$API/postgres/$POSTGRES_ID" \
        -H "Authorization: Bearer $RENDER_API_KEY")

    STATUS=$(jq -r '.status // empty' <<< "$POSTGRES_DETAILS")

    echo "Status: $STATUS ($attempt/60)"

    if [ "$STATUS" = "available" ]; then
        AVAILABLE=true
        break
    fi

    if [[ "$STATUS" == "suspended" ||
        "$STATUS" == "unavailable" ||
        "$STATUS" == "recovery_failed" ]]; then

        echo "ERROR: Database cannot become available: $STATUS"
        exit 1
    fi

    if [ "$attempt" -eq 60 ]; then
        echo "ERROR: Database startup timeout."
        exit 1
    fi

    sleep 10

done

if [ "$AVAILABLE" != true ]; then
    echo "ERROR: Database is not available."
    exit 1
fi

# 9. Kapcsolódási adatok lekérése.
echo
echo "Retrieving database credentials..."

CONNECTION_INFO=$(curl --fail-with-body --silent --show-error \
    "$API/postgres/$POSTGRES_ID/connection-info" \
    -H "Authorization: Bearer $RENDER_API_KEY")

EXTERNAL_DB_URL=$(jq -er '.externalConnectionString' \
    <<< "$CONNECTION_INFO")

DB_PASS=$(jq -er '.password' <<< "$CONNECTION_INFO")

# 10. Kapcsolati adatok feldolgozása.
DB_VALUES=$(EXTERNAL_DB_URL="$EXTERNAL_DB_URL" python3 <<'PY'
import os
from urllib.parse import urlparse, unquote

url = os.environ["EXTERNAL_DB_URL"]
parsed = urlparse(url)

if not parsed.hostname or not parsed.username or not parsed.path:
    raise SystemExit("Invalid database connection URL.")

print(unquote(parsed.hostname))
print(parsed.port or 5432)
print(unquote(parsed.username))
print(unquote(parsed.path.lstrip("/")))
PY
)

mapfile -t DB_VALUES <<< "$DB_VALUES"

if [ "${#DB_VALUES[@]}" -ne 4 ]; then
    echo "ERROR: Could not parse database connection details."
    exit 1
fi

DB_HOST="${DB_VALUES[0]}"
DB_PORT="${DB_VALUES[1]}"
DB_USER="${DB_VALUES[2]}"
DB_NAME="${DB_VALUES[3]}"

if [[ "$DB_NAME" != "$POSTGRES_DATABASE_NAME"* ]]; then
    echo "ERROR: Unexpected internal database name: $DB_NAME"
    exit 1
fi

SPRING_DB_URL="jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=require"

# 11. .env fájl létrehozása a projekt gyökerében.
echo
echo "Creating .env file..."

cd "$PROJECT_DIR"

DB_URL_VALUE="$SPRING_DB_URL" \
DB_USER_VALUE="$DB_USER" \
DB_PASS_VALUE="$DB_PASS" \
python3 <<'PY'
import os

def escape(value):
    return (value
            .replace("\\", "\\\\")
            .replace('"', '\\"')
            .replace("$", "\\$")
            .replace("`", "\\`"))

with open(".env", "w") as file:
    file.write(f'DB_URL="{escape(os.environ["DB_URL_VALUE"])}"\n')
    file.write(f'DB_USER="{escape(os.environ["DB_USER_VALUE"])}"\n')
    file.write(f'DB_PASS="{escape(os.environ["DB_PASS_VALUE"])}"\n')

os.chmod(".env", 0o600)
PY

echo ".env created successfully!"

# 12. Render web service megkeresése.
echo
echo "Searching for Render web service..."
echo "Service name: $WEB_SERVICE_NAME"

mapfile -t WEB_SERVICE_IDS < <(find_web_service)

if [ "${#WEB_SERVICE_IDS[@]}" -eq 0 ]; then
    echo "ERROR: Render web service not found."
    echo "Environment variables were not updated."
    exit 1
fi

if [ "${#WEB_SERVICE_IDS[@]}" -gt 1 ]; then
    echo "ERROR: Multiple web services named $WEB_SERVICE_NAME found."
    echo "Environment variables were not updated."
    exit 1
fi

WEB_SERVICE_ID="${WEB_SERVICE_IDS[0]}"

echo "Web service found: $WEB_SERVICE_ID"

# 13. Render Environment Variables frissítése.
echo
echo "Updating Render environment variables..."

update_web_env_var "DB_URL" "$SPRING_DB_URL"
update_web_env_var "DB_USER" "$DB_USER"
update_web_env_var "DB_PASS" "$DB_PASS"

echo
echo "All database environment variables updated!"

# 12. PostgreSQL csatlakozás és tábla létrehozása.
echo
echo "Connecting to PostgreSQL..."

PGPASSWORD="$DB_PASS" psql \
    "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER sslmode=require" \
    -v ON_ERROR_STOP=1 <<'SQL'

CREATE TABLE IF NOT EXISTS animals (
    uid SERIAL PRIMARY KEY,
    name VARCHAR(255),
    weight INTEGER
);

\dt

SQL

# 14. Új deployment indítása.
echo
echo "Triggering Render deployment..."

if ! DEPLOY_HTTP_STATUS=$(curl --silent --show-error \
    --output /dev/null \
    --write-out '%{http_code}' \
    --request POST \
    "$API/services/$WEB_SERVICE_ID/deploys" \
    -H "Authorization: Bearer $RENDER_API_KEY" \
    -H "Accept: application/json"); then

    echo "ERROR: Could not trigger deployment."
    exit 1
fi

if [[ "$DEPLOY_HTTP_STATUS" != "201" &&
      "$DEPLOY_HTTP_STATUS" != "202" ]]; then

    echo "ERROR: Deployment request failed."
    echo "HTTP status: $DEPLOY_HTTP_STATUS"
    exit 1
fi

echo "Deployment successfully requested!"

unset DB_PASS

echo
echo "======================================"
echo " SUCCESS!"
echo "======================================"
echo
echo "Render service: $POSTGRES_NAME"
echo "Database: $DB_NAME"
echo "PostgreSQL version: $POSTGRES_VERSION"
echo "Table: animals"
echo ".env: $PROJECT_DIR/.env"
echo
