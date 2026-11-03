# render.com-os api beállítása

Jobb szélén Account Settings menüpont.
Görgess az API Keys szekcióhoz.
Kattints a Create API Key gombra.
Adj neki nevet pl.: animal-shelter-linux-mint
Create API Key gombra katt.
Másold ki, többet nem fogod látni az api-keyt.

A gépeden mentsd el így: 
`mkdir -p ~/.config/render`

A parancs a felhasználó saját fiókjának (home könyvtárának) rejtett beállítási mappájába hoz létre egy render nevű könyvtárat.

`nano ~/.config/render/api-key`

Másold be a Render által generált API-kulcsot.

Mentsd el:
- Ctrl + O
- Enter
- Ctrl + X

Jogosultság beállítása:
`chmod 600 ~/.config/render/api-key`
Így csak a saját felhasználód olvashatja a fájlt.

Ellenőrzés: `ls -l ~/.config/render/api-key`
Ha ilyet látsz pl.: -rw------- 1 user user ... api-key  ,akkor el van mentve.

Kapcsolat ellenőrzése és db-k lekérése:
```bash
API_KEY="$(< "$HOME/.config/render/api-key")"

set -o pipefail

curl --fail --silent --show-error \
  "https://api.render.com/v1/postgres?limit=100" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  | jq -r '.[] | [.postgres.name, .postgres.id, .postgres.status] | @tsv'

unset API_KEY
```

# Adatbázis létrehozása a Render.com-on

A render.com-on hozz létre egy Postgres-t. A név legyen "database". A verzió 16-os, a lényeg hogy egyezzen a gépre feltepített verzióval. Region: EU Instance Type: Free -> Create Database

Miután elkészült szükséged lesz az External Database URL-re, Username, Database, Password-re.

Futtathatóvá tétel
Nyisd meg a terminált a projekt gyökérkönyvtárában:
```bash
cd /home/andi/Dokumentumok/GitHub/animal-shelter/docs
chmod +x restore-database.sh
./restore-database.sh
```
```bash
chmod +x setup-github-secrets.sh
./setup-github-secrets.sh
```
```bash
git add .
git commit -m "fix: create a new connection to brand new database "
git push
```
