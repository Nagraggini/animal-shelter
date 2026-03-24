# Miről szól ez a projekt?

Ez a projekt a Spring Boot alapjait mutatja be kezdők számára, lépésről lépésre.

Célja, hogy:
- megértsd a Spring Boot működését
- megtanuld egy teljes webalkalmazás felépítését
- lásd a backend + frontend + adatbázis kapcsolatot

A projekt egy egyszerű "Animal Shelter" alkalmazáson keresztül mutatja be a CRUD műveleteket.

# Tartalomjegyzék

- [Miről szól ez a projekt?](#miről-szól-ez-a-projekt)
- [Tartalomjegyzék](#tartalomjegyzék)
- [Kezdőknek](#kezdőknek)
- [Spring Boot](#spring-boot)
- [Új projekt létrehozása](#új-projekt-létrehozása)
- [Dockerfile](#dockerfile)
  - [Dockerfile tartalma](#dockerfile-tartalma)
- [Projekt feltöltése githubra és render.com-ra](#projekt-feltöltése-githubra-és-rendercom-ra)
  - [SSH key](#ssh-key)
  - [Build failed](#build-failed)
- [Projekt futtatása](#projekt-futtatása)
- [BL Business Logic - Java logika](#bl-business-logic---java-logika)
  - [Controllers mappa](#controllers-mappa)
    - [HTTP módszerek:](#http-módszerek)
  - [Models mappa](#models-mappa)
- [Tailwind stílus használata](#tailwind-stílus-használata)
- [CI/CD (Continuous Integration / Continuous Deployment) folyamat:](#cicd-continuous-integration--continuous-deployment-folyamat)
- [Debug](#debug)
- [Templating with Spring and Thymeleaf](#templating-with-spring-and-thymeleaf)
- [Portok használata](#portok-használata)
- [Adatbázisok](#adatbázisok)
    - [Windows-on:](#windows-on)
    - [Linux-on:](#linux-on)
  - [Adatbázis létrehozása a Render.com-on](#adatbázis-létrehozása-a-rendercom-on)
  - [\\dt-vel kilistázzuk a kettő táblát:](#dt-vel-kilistázzuk-a-kettő-táblát)
  - [\\d animals-vel a tábla struktúráját láthatod:](#d-animals-vel-a-tábla-struktúráját-láthatod)
- [application.properties fájl](#applicationproperties-fájl)
- [Teljes Flow](#teljes-flow)
- [Spring Session](#spring-session)
- [Teszteléshez](#teszteléshez)
  - [Gyors módszer az adatbázis eléréséhez:](#gyors-módszer-az-adatbázis-eléréséhez)
  - [Futtatás localhost-on](#futtatás-localhost-on)
- [REST API](#rest-api)
  - [Régi non rest api-s controller](#régi-non-rest-api-s-controller)
    - [non-rest api-s showAll.html](#non-rest-api-s-showallhtml)
  - [Extra infó](#extra-infó)
    - [Noreferrer](#noreferrer)
  - [Projekt struktúra](#projekt-struktúra)
  - [Helyes mappa struktúra](#helyes-mappa-struktúra)
  - [Rendszer](#rendszer)
  - [Postman](#postman)
  - [Endpoints](#endpoints)
- [JUnit tesztek futtatásához](#junit-tesztek-futtatásához)
  - [Online DB-vel való teszteléshez](#online-db-vel-való-teszteléshez)
    - [GitHub Secrets beállítása](#github-secrets-beállítása)
    - [maven.yml](#mavenyml)
    - [Engedélyezzük a db elérést](#engedélyezzük-a-db-elérést)
  - [Offline H2 DB-s teszteléshez](#offline-h2-db-s-teszteléshez)
  - [AnimalShelterApplicationTests.java fájl tartalmának módosítása](#animalshelterapplicationtestsjava-fájl-tartalmának-módosítása)
- [Local teszthez](#local-teszthez)
- [JUnit teszt kiírása a fő oldalra és készítése](#junit-teszt-kiírása-a-fő-oldalra-és-készítése)
  - [Release](#release)
  - [Tesztlefedettség ellenőrzése (jacoco)](#tesztlefedettség-ellenőrzése-jacoco)
- [auto-squash](#auto-squash)
- [Online fejlesztéshez](#online-fejlesztéshez)

# Kezdőknek

[Saját webfejlesztői alapismeretekről szóló blogom](https://nagraggini-blog.onrender.com/)

# Spring Boot

[Ez alapján csináltam.](https://www.youtube.com/watch?v=RK6aAjUMcl0&list=PLg7lel5LdVjyO7jk-4biyr0fqPVygTLOk)

[A fenti youtube videóhoz tartozó repo.](https://github.com/bobbychansfu/springboot-render/tree/7d38d0343465661adceb6372591a8353717dfd5e)

További link:
[Spring MVC Beginner](https://www.youtube.com/watch?v=VqptK6_icjk&list=PL82C6-O4XrHejlASdecIsroNEbZFYo_X1)

[Fejlesztői környezet és kiegészítők letöltése](https://code.visualstudio.com/docs/java/java-spring-boot)

A vs code extension részen ezeket töltsd le:

- Java Development Kit (JDK)
- Extension Pack for Java
- Spring Boot Extension Pack
- Spring Boot Tools
- Spring Initializr

# Új projekt létrehozása

Előre konfigurált Spring Boot projektet lehet generáltatni, hogy ne kelljen kézzel megírni az összes kezdő fájlt és beállítást: [Spring Initializr](https://start.spring.io/)

Project: Maven
Language: Java
Spring Boot: 4.0.2
Artifact és Name: projektneve, amit az elején megadtál.
Packaging: Jar
Conf: Properties
Java: 17

Dependenciák:
Spring Boot DevTools (Fejlesztéshez kell, éles appba nem, gyorsabb újraindítás és nem kell kézzel leállítani és újrainsítani a szervert.)
Spring Web (Webalkalmazáshoz kell, hogy legyen @Controller osztály, HTTP kérések kezelés.)
Spring Session for JDBC (Arra való, hogy a session adatokat adatbázisban tárolja. Egyszerű CRUD-nál nem szükséges.)
Thymeleaf (Java változók megjelenítésében HTML-ben.)
Spring Data JPA  
(Ez az ORM réteg. Entity osztályok használatához és CRUD müveletekhez.
CRUD:  
 C – Create → létrehozás  
 R – Read → lekérdezés / olvasás  
 U – Update → módosítás  
 D – Delete → törlés)  
Spring Data JDBC (JPA-hoz hasonló, de nincs komplex ORM működik. Alapból elég a JPA csa.)
H2 Database (Ez egy beépített, memóriában futó adatbázis. Gyors teszthez jól jön, amúgy nem kell mert PostgreSQl adatbázis van.)
PostgreSQL Driver (Ez a driver teszi lehetővé, hogy az alkalmazás kapcsolódjon a PostgreSQL adatbázishoz)

# Dockerfile

Az alkalmazás győkér könyvtárába hozd létre egyből a Dockerfile, ne adj neki kiterjesztést, txt-t sem.

Ez a Dockerfile a Spring Boot alkalmazás konténerizálására szolgál.

A célja, hogy az alkalmazásodat lefordítsa és futtassa egy Docker konténerben, így bárhol ugyanúgy működjön (Render, saját gép, stb.).

Ez az egész Dockerfile arra kell, hogy:

- lefordítsa a Spring Boot projektet
- JAR fájlt készítsen
- elindítsa egy konténerben

## Dockerfile tartalma

```
# Build stage: a projekt lefordítása és JAR csomagolása Maven segítségével.
# Java verzió a pom.xml-ben van beállítva (Java 17).

# A from sor létrehoz egy ideiglenes konténert.
FROM maven:3.8.5-openjdk-17 AS build
# Fordításra szolgál.
WORKDIR /app
COPY . .

# Lefordítja a Java kódot és létrehozza a JAR fájlt. Ezt a jar fájlt használjuk lentebb a copy sorban.
RUN mvn clean package -DskipTests

# Run stage: ez a konténer fogja futtatni az alkalmazást.
# Java verzió a pom.xml-ben van beállítva (Java 17).
FROM openjdk:17.0.1-jdk-slim
WORKDIR /app

# Ez átmásolja a fentebb létrehozott JAR fájlt a build stage-ből a run stage-be (/app/animal_shelter.jar).
COPY --from=build /app/target/*.jar animal_shelter.jar

# A Spring Boot alkalmazás a 8080-as porton fut.
EXPOSE 8080

# Alkalmazás futtatása. ENTRYPOINT: a konténer indításakor a JAR futtatása.
ENTRYPOINT ["java","-jar","animal_shelter.jar"]
```

# Projekt feltöltése githubra és render.com-ra

https://github.com/-ra regisztrálj be.

Github Desktop-t töltsd le. Utána File -> Add local repository-> keresd meg a mappát, ahova az új projektet hoztad létre. -> Add repository -> Create a repoditory -> Töltsd ki az űrlapot. -> Create repository

render.com regisztrálj -> Kösd össze a github fiókoddal.

New -> Web Service -> Válaszd ki a listából a progjekt nevét (animal_shelter)
Language: Docker
-> Deploy web service Kb 15 percig eltart a deploy.

## SSH key

Ez alapján hozd létre: https://github.com/settings/ssh/new

## Build failed

Ha valamit elrontottál is kijavítod, utána a render.com-on -> Manual Deploy -> Deploy latest commit

# Projekt futtatása

Ha elindítod a java fájlt (AnimalShelterApplication.java), akkor a böngészőbe írd be ezt: http://localhost:8080/actuator

A dependenciák közt fel vettek az actuatort, ezzel le tudod csekkolni magad.
Az actuator információt ad az alkalmazás állapotáról és működéséről.

Alapból csak a /actuator endpoint lesz elérhető.

Ha több információt akarsz, a application.properties-ben beállíthatod, pl.:
management.endpoints.web.exposure.include=\*

A static mappába hozz létre egy index.html fájlt.

A static mappában lévő html fájlt, itt meg tudod nézni:
http://localhost:8080/index.html

showAll.html fájlt ide hozd létre: animal_shelter/src/main/resources/templates/animals
http://localhost:8080/animals/view

# BL Business Logic - Java logika

Egy régebbi konzolos java projekt fájljait másold be is:
GitHub/animal_shelter/src/main/java/com/example/animal_shelter/models

A Spring Boot architektúra alapja, hogy a MVC mintát használja:

Model – View – Controller

## Controllers mappa

A Controller réteg fogadja a HTTP kéréseket.

### HTTP módszerek:

- `GET`: Adatok lekérése
- `POST`: Új adat létrehozása
- `PUT`: Adat frissítése
- `DELETE`: Adat törlése

Például:

GET /users
POST /addUser

A controller:

- Fogadja a requestet.
- Meghívja a service-t / repository-t.
- Visszaad egy view-t, jelen esetben ez lesz, majd /animals/view. [View (Thymeleaf) = megjelenítés]

## Models mappa

A Model egy Java osztály, ami:

- Az adatbázis egy tábláját reprezentálja.
- Az osztály példányai egy-egy rekordnak felelnek meg.
- JPA segítségével automatikusan össze van kötve az adatbázissal.

osztály = tábla
objektum = sor
mező = oszlop

Az annotáció (@) jelzi a Spring/JPA számára, hogy ez egy adatbázis entitás.

```bash
@Entity
@Table(name = "animals") //Megmondja, hogy melyik adatbázis táblához tartozik.
public class Animal {

  // Ezek az elsődleges kulcs létrehozásához kellenek. Az animals adattáblában van
	// egy uid oszlopunk.
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY) // Lefogja generálni az értékét.
	private int uid;

//Utána jönnek a konstruktorok, getterek/setterek és metódusok.

}
```

# Tailwind stílus használata

Node.js-t telepítsd. Linux-on írd be a terminálba, hogy: sudo apt update
Utána: sudo apt install nodejs

npm-et is telepítsd -> sudo apt install npm

Így csekkold, hogy le van-e töltve:
node -v
npm -v

[Tailwind](https://tailwindcss.com/docs/animation)

A HTML-ben a head tagbe másold be ezt:

    <script src="https://cdn.tailwindcss.com"></script>

A Tailwind CSS IntelliSense kiegészítőt ajánlott telepíteni a vs code-on.

# CI/CD (Continuous Integration / Continuous Deployment) folyamat:

Új build indítása – Ez lehet manuális push a GitHub/GitLab branchre, vagy egy automatikus trigger.

Dockerfile feldolgozása – A rendszer végigmegy a Dockerfile-on: letölti a base image-et, telepíti a függőségeket, lefordítja a projektet (pl. mvn package), és létrehozza a végső Docker image-et.

Image létrehozása – Ez a “build” lépés, ahol a kész alkalmazás becsomagolódik egy konténerbe.

Image deployolása – Render.com feltölti az image-et a saját konténer registry-jébe és elindítja az új konténert.

Új konténer futtatása – Az új image futtatása a szerveren, a régi konténer lecserélődik (rolling update).

A folyamat 10 perc körüli időt vesz igénybe, mert a Maven build és a Docker image létrehozása időigényes lehet, főleg ha a projekt nagy vagy sok függőséget használ (Ez 8 db-ot használ).

# Debug

[A videó végén szerepel, hogyan kell debuggolni.](https://www.youtube.com/watch?v=p3AIecyvok4&list=PLg7lel5LdVjyO7jk-4biyr0fqPVygTLOk&index=7)

1. Telepítsd a Docker-t.

2. Projekt buildelése Dockerrel:
   Terminálba írd be: sudo docker build -t renderapp .

- A . a build context, azaz a Docker a projekt gyökérkönyvtárából veszi a Dockerfile-t és a forrásfájlokat.
- A parancs létrehoz egy Docker image-et, ami tartalmazza a Maven build-et és az alkalmazást.

3. Mi történik a háttérben:

- A Docker először letölti a base image-et (pl. Maven + JDK).
- Lefuttatja a mvn clean package parancsot, ami:
  Kitisztítja a korábbi build fájlokat
  Létrehozza a target mappát
  Becsomagolja az alkalmazást futtatható .jar fájlba
- A .jar fájl bekerül a Docker image-be, így az image futásra kész lesz.

Felhasználót hozzáadni a docker csoporthoz (jobb hosszú távon):
Terminálba:
sudo usermod -aG docker $USER
newgrp docker

Ez a parancs elindít egy Docker konténert az általad készített renderapp image-ből, és biztosítja, hogy a konténeren belüli 8080-as portot elérd a saját gépedről a localhost:8080 címen:
docker run -p 8080:8080 renderapp

# Templating with Spring and Thymeleaf

Spring és Thymeleaf használatakor a templatingre azért van szükség, hogy dinamikus funkciókat és adatokat jeleníthessünk meg az oldalon.

A templates mappában találhatók a view-k, vagyis a kinézetek.

A models mappában lévő java fájlokkal kezeljük a felhasználókat. (vagy objektumokat, szolgáltatásokat)
A controllers figyeli a szervert, és lehetővé teszi, hogy információkat kapjunk a felhasználókról.

UserController.java vizuális ábrán:  
[Felhasználó / Kliens]  
|  
| GET http://localhost:8080/users/view  
v

---

| UsersController                              |
| -------------------------------------------- |
| @GetMapping("/users/view") --> getAllUsers() |

---

          |
          | Visszatérési érték: "users/showAll"
          v

---

| Thymeleaf Template |
| templates/users/showAll.html |

---

          |
          v

[Böngésző megjeleníti a felhasználónak]

A templates mappában lévő html fájlok rejtve vannak a felhasználó elől, nem úgymint a static mappában lévők.

[Thymeleaf](https://www.thymeleaf.org/doc/tutorials/3.1/usingthymeleaf.html)

# Portok használata

Ezzel kilistázod, hogy melyik app használja a portot.

Terminálban:
sudo lsof -i :8080

A 58608-at írd át arra, amit fentebb kiír.
sudo kill 58608

# Adatbázisok

Az adatbázisokat alapvetően két fő kategóriába soroljuk:

- strukturált adatbázisok
- nem strukturált adatbázisok (A kezdők struktúráltat használnak, lekérdezéshez pedig sql-t.)

Postgresql-t [innen](https://www.postgresql.org/download/) tudod letölteni. Verzió: 16.11 Egyezzen lentebb létrehozott render.com-os adatbázissal.

A PostgreSQL működhet:

- szerverként (adatbázis szerver)
- kliensként (adatbázis kezelő eszköz)

Ebben az esetben neked csak a kliensre lesz szükséged, mert az adatbázis szerver a render.com platformon fog futni, és ahhoz távolról fogsz csatlakozni.

### Windows-on:

Környezeti változó beállítása: PowerShell:setx PATH "$env:PATH;C:\Program Files\PostgreSQL\16\bin" 

Lecsekkoljuk a verziót -> Cmd:cd "C:\Program Files\PostgreSQL\16\bin"psql --version Terminálban.

### Linux-on:

Terminálban:
sudo apt update
sudo apt install postgresql

[Postgesql hivatalos honlapja](https://www.postgresql.org/download/linux/ubuntu/)

## Adatbázis létrehozása a Render.com-on

A render.com-on hozz létre egy Postgres-t. A név legyen database. A verzió 16-os, a lényeg hogy egyezzen a gépre feltepített verzióval. Region: EU Instance Type: Free -> Create Database

Miután elkészült szükséged lesz az External Database URL-re, Username, Database, Password-re.

Terminálban, csatlakoztasd Postgres-t a render.com-os adatbázissal:
psql -h "@-utáni résztől....frankfurt-postgres.render.com-ig" -U "Username" -d "Database"
Entert nyomj.
pl.: psql -h dpg-d69k87buibrs739i5fu0-a.frankfurt-postgres.render.com -U database_olpd_user -d database_olpd
A jelszónak az oldalon lévő password-t másold be. Nem fogja mutatni. Majd entert nyomj.

Adatbázis létrehozása a terminálban:
CREATE TABLE animals (uid SERIAL, name VARCHAR(255), weight INTEGER);

## \dt-vel kilistázzuk a kettő táblát:

```bash
               List of relations

Schema | Name | Type | Owner
--------+----------+-------+--------------------
public | animals | table | database_olpd_user

```

## \d animals-vel a tábla struktúráját láthatod:

```bash
                                    Table "public.animals"
 Column |          Type          | Collation | Nullable |               Default
--------+------------------------+-----------+----------+--------------------------------------
 uid    | integer                |           | not null | nextval('animals_uid_seq'::regclass)
 name   | character varying(255) |           |          |
 weight | integer                |           |          |

```

A "q"-val tudsz kilépni belőle.

Így tudsz hozzáadni plussz sort (objektum):
INSERT INTO animals (name,weight) VALUES ('Cirma',15);

Kilistázás:
SELECT \* FROM animals;

A vs code-ban a pom.xml-hez adjuk hozzá a postgresql drivert. Jobb klikk a pom.xml-en -> Add Starts.. -> Postgresql Driver -> Enter -> Proceed.

Az application.properties fájlban rendeljük össze a weboldalt a render.com-os adatbázissal.

# application.properties fájl

src/main/resources/application.properties

```
spring.application.name=animal_shelter

# Debughoz engedélyezzük a Tomcat access logot
server.tomcat.accesslog.enabled=true

# Automatikusan módosítja az adatbázist.
#Ha hozzáadsz egy új oszlopot az egyik tábládhoz, akkor ez automatikusan feltölti az új oszlopot az adatbázisba.
spring.jpa.hibernate.ddl-auto=update
# Minden SQL lekérdezést kiír a konzolra (debughoz hasznos).
spring.jpa.show-sql=true

#Formázza és kommenteli az SQL lekérdezéseket a konzolban.
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.use_sql_comments=true

#Protokoll (Az adatokat a környezeti változóban találod.)
# render.com-on láthatod ezeket az infókat:
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASS}

# Elmentjük a logokat egy fájlba. A logokat a Controllers osztályból szedi. Kb a syso-k összegyűjtése.
logging.file.name=logs/animals.log
logging.level.com.example.animal_shelter.controllers=INFO

#Miután a fentieket beállítottad, újra kell indítani a szervert.
```

A gyökér könyvtárba hozz létre egy .env fájlt.

Tartalma:
DB_URL=jdbc:postgresql://dpg-d69k87buibrs739i5fu0-a.frankfurt-postgres.render.com/database_olpd
DB_USER=Nagraggini
DB_PASS=root

Majd menj fel a render.com-ra az adatbázis infó részén láthatod az Internal Database URL-t másold ki.
Aztán a render.com-on a nem rég feltöltött web service-re menj rá. -> Environment -> Environment Variables -> Add melletti kicsi nyílra nyomj. -> Import from .env -> Másold ide a fájl tartalmát. -> Add variables.

A felhasználónevet és jelszót módosítsd arra, amit a render.com-on látsz.
A hozzáadott DB_URL-hez másold be az Internal Database URL-t az alábbi módosításokat eszközöld rajta.

pl.: postgresql://*database_olpd_user:sekoojWQ5YUGrgC3080avcnkVvgY4LSQ@*dpg-d69k87buibrs739i5fu0-a/database_olpd

A csillagok között lévő részt töröld ki. 
Az elejére ezt írd: jdbc:

Aztán save, rebuild and deploy gombra nyomj.

# Teljes Flow

Browser  
 │  
 │ POST /users/add  
 │ name=Cirmi  
 │ password=1234  
 │ size=42  
 ▼  
Controller  
 │  
 │ new Animal(...)  
 ▼  
Repository  
 │  
 ▼  
Database  
 │  
 ▼  
HTML response: showAll.html

# Spring Session

Ha nem akarod használni:
application.properties-be másold be ezt "spring.session.store-type=none"

Ezzel Spring nem próbálja létrehozni vagy használni a spring_session táblát, és nem kapsz hibát a lejárt session-ök törlésekor.

Ha naplózni akarod az adatokat:

Akkor létre kell hozni a táblát az adatbázisban, miután kapcsolódtál hozz a terminálban.

Ezt másold be a terminálba:

CREATE TABLE spring_session (
primary_id CHAR(36) NOT NULL,
session_id CHAR(36) NOT NULL,
creation_time BIGINT NOT NULL,
last_access_time BIGINT NOT NULL,
max_inactive_interval INT NOT NULL,
expiry_time BIGINT NOT NULL,
principal_name VARCHAR(100),
CONSTRAINT spring_session_pkey PRIMARY KEY (primary_id)
);

CREATE UNIQUE INDEX spring_session_ix1 ON spring_session (session_id);
CREATE INDEX spring_session_ix2 ON spring_session (expiry_time);
CREATE INDEX spring_session_ix3 ON spring_session (principal_name);

Ezután a Spring Session JDBC automatikusan használni fogja ezt a táblát a session-ök tárolására és lejárt session-ök törlésére.

# Teszteléshez

## Gyors módszer az adatbázis eléréséhez:

Postgresql-t [innen](https://www.postgresql.org/download/) tudod letölteni. Verzió: 16.11 Egyezzen fentebb létrehozott render.com-os adatbázissal. A telepítésközben a render.com-ról kell ki másolni az adatbázis jelszót, meg a többit. Az adatbázist be kell állítani a fentebb leírt módon.

A terminálba másold be a render.com-ról a PSQL Command-ot.
psql -h dpg-d6u0j24r85hc73fgjfr0-a.frankfurt-postgres.render.com -U database_5kzt_user -d database_5kzt

Minden adat törlése, kivéve Cirmit:
DELETE FROM animals WHERE name <> 'Cirmi';

Adatmódosítás:
UPDATE animals
SET name = 'Morzsi'
WHERE uid =44;

A táblát így tudod csekkolni a terminálban:
\d animals
q-val tudsz kilépni.

Listázás:
SELECT \*
FROM animals;

## Futtatás localhost-on

A AnimalShelterApplication.java fájl legyen megnyitva aktuálisan.

Nyomd meg a start gombot, hogy localhost-on tesztelt az weboldalt. Vagy a Spring Boot Dashboard-on a start gombra menj, akár mi meg lehet nyitva jobb oldalt.

Ha az oldal elindult, a terminálban ezt kell látnod:  
Started AnimalShelterApplication in 9.588 seconds (process running for 10.541)

Ha nem indul el, keresd meg a terminálban az ERROR-t.

Böngészőbe írd be: http://localhost:8080/  
F12 (DevTools) → Network fülön könnyebb ellenőrizni.

Szerver leállítása: IDE-ben a Stop gomb, Linux-on a terminálban Ctrl+C.

# REST API

A Spring Boot (Jackson) automatikusan átalakítja a bejövő JSON-t (@RequestBody) Animal objektummá, és vissza is JSON-t küld (@RestController).

Fontos:

A kliensnek Content-Type: application/json-et kell küldenie.
A kérés törzse (body) legyen pl. { "name": "Buksi", "weight": 5 }.
A szerver oldalon a Animal osztály getter/setter-ei legyenek rendben (nálatok vannak).
Példa curl-lel:

Tehát nem kell külön JSON fájl a projektben, a JSON a kérés része (vagy ha HTML/JS-ből küldöd, akkor a fetch body-ja).

[Rest api](https://www.youtube.com/watch?v=Zo9xQzibp4Y)

## Régi non rest api-s controller

package com.example.animal_shelter.api.controllers;

//ArrayList-hez:
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.animal_shelter.models.Animal;
import com.example.animal_shelter.repository.AnimalRepository;
import com.example.animal_shelter.service.AnimalService;

import jakarta.servlet.http.HttpServletResponse;

// Ez a kontroller figyeli a szervert, és lehetővé teszi, hogy információkat kapjunk a felhasználókról.
@RestController
public class AnimalsController {

    // syso helyett:
    private static final Logger logger = LoggerFactory.getLogger(AnimalsController.class);

    @Autowired
    private AnimalRepository animalRepo;

    @GetMapping("/add.html")
    public String addPage() {
        return "add";
    }

    // Ez a metódus akkor fut le, ha a felhasználó HTTP GET kérést küld a
    // /users/view URL-re.
    // A @GetMapping annotáció egy endpointot definiál, amin keresztül a kliens
    // kapcsolatba léphet a szerverrel.
    // A visszatérési érték "users/showAll" a Thymeleaf template neve, amit a
    // böngészőnek küldünk.
    @GetMapping("/animals/view")
    // Model -> org.springframework.ui -> Be is kerül fentre az importokhoz.
    public String getAllAnimals(Model model) {
        // Modell: A Spring MVC-ben a Model egy olyan “csomagoló” objektum, amiben
        // adatokat küldünk a HTML template-nek (Thymeleaf, JSP, stb.).
        logger.info("Getting all animals."); // info szintű log

        // Mindegyik állat lekérése az adatbázisból.
        List<Animal> animals = animalRepo.findAll();
        // Vége az adatbázis meghívásnak.

        // A modellhez hozzáadjuk az adatokat.
        // "ani" – ez a név, amin keresztül a template-ben el tudjuk érni.
        model.addAttribute("ani", animals);

        // A "users/showAll" a Thymeleaf template neve, amit visszaad a böngészőnek
        // A templates mappában van a showAll.html, ami meg fog jelenni.
        // A return "users/showAll"; csak a template nevét adja vissza, amit a Spring
        // MVC feldolgoz és a böngészőnek renderel.
        return "animals/showAll";
        // A böngésző nem kapja közvetlenül a Model objektumot, csak a renderelt HTML-t.
    }

    // Ez a metódus a Spring Boot backend egyik endpointja, amely fogadja a HTML
    // form által küldött adatokat, majd elmenti az adatbázisba.
    @PostMapping("/animals/view") // Ez definiál egy HTTP endpointot, ami az add.html fájlban van.

    // @RequestParam Map<String, String> newuser -> Összegyűjti a form mezőket egy
    // Map-be.
    // A newanimal -> Egy kulcs-érték lista.
    // HttpServletResponse response -> Ez a HTTP válasz objektum.
    public String addAnimal(@RequestParam Map<String, String> newanimal, Model model, HttpServletResponse response) {

        logger.info("Add animal.");

        // A html-ben lévő name attribútumra hivatkozunk a jobb oldalon.
        String newName = newanimal.get("name");
        String weightStr = newanimal.get("weight");

        // Ellenőrizzük, hogy a mezők ki vannak-e töltve
        if (newName == null || newName.isBlank() || weightStr == null || weightStr.isBlank()) {
            model.addAttribute("error", "Name and weight are required!");
            return "add"; // vissza a formhoz, hibaüzenettel
        }

        int newWeight;
        try {
            newWeight = Integer.parseInt(weightStr);
        } catch (NumberFormatException e) {
            logger.error("Failed to parse weight: " + weightStr, e);
            model.addAttribute("error", "Hibás input!");
            return "add"; // vissza a formhoz, hibaüzenettel
        }

        // Ezzel mentjük az adatbázisba a sort. Kb egy INSERT INTO ...
        // Ez az ORM (Object-Relational Mapping). Az ORM (itt a Spring Data JPA) kezeli
        // az objektum → adatbázis leképezést.
        animalRepo.save(new Animal(newName, newWeight)); // Jobb oldalt az Animal osztály konstruktorát hívjuk meg.
        response.setStatus(201); // Beállítja a HTTP válasz státuszkódját 201-re, vagyis Created.

        // Ez visszaad egy HTML oldalt. A Spring megkeresi ezt: templates/animals/
        // Átirányítás a listázó oldalra.
        // Redirect POST után: Jó a (PRG – Post/Redirect/Get), így frissítésnél
        // nem ismétlődik a POST, nem lesz duplikáció!
        return "redirect:/animals/view";

    }

}

### non-rest api-s showAll.html

 <!--th =thymeleaf
                    each=foreach
                    us a modelből jön.
                    Végigmegyünk a us listán, minden elem animal néven lesz elérhető a <tr>-ban.-->

                    <table class="table-auto border-collapse w-full">
                        <thead>
                            <tr class="bg-blue-200">
                                <th class="border px-4 py-2">Name</th>
                                <th class="border px-4 py-2">Weight</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!--Ez egy foreach:-->
                            <!-- Az AnimalsController.java-ban a model.addAttribute("ani", animals") segítségével hivatkozunk a modelre. -->
                            <!--A lenti sorban kell a szóköz a kettőspont előtt!-->
                            <tr
                                th:each="animal:${ani}"
                                class="hover:bg-gray-100"
                            >
                                <td
                                    th:text="${animal.name}"
                                    class="border px-4 py-2"
                                ></td>
                                <td
                                    th:text="${animal.weight}"
                                    class="border px-4 py-2"
                                ></td>
                            </tr>
                        </tbody>
                    </table>

[Ez az utolsó olyan commit, ami non rest-api-s.](https://github.com/Nagraggini/animal_shelter/tree/61a0c6bb471e8ae1fa593e8652c99f3d301ea836)

## Extra infó

### Noreferrer

A rel="noreferrer" HTML-attribútum megakadályozza, hogy a böngésző elküldje a forrásoldal adatait a céloldalnak, így növeli a biztonságot és a magánélet védelmét.

```bash
 <a rel="noreferrer"
                    href="https://github.com/Nagraggini/animal_shelter"
                    class="text-blue-600 hover:underline"
                >
                    Source code
                </a>
```

## Projekt struktúra

Spring Boot

- REST API
- JPA
- Service layer
- Repository layer

Thymeleaf (A megjelenítéshez.)

## Helyes mappa struktúra

```bash
ANIMAL_SHELTER
│
├─ src
│  └─ main
│     ├─ java
│     │  └─ com
│     │     └─ example
│     │        └─ animalshelter
│     │           │
│     │           ├─ controllers
│     │           │   └─ AnimalsPageController
│     │           │   └─ ApiAnimalsController.java
│     │           │
│     │           ├─ models
│     │           │   └─ Animal.java
│     │           │
│     │           ├─ repository
│     │           │   └─ AnimalRepository.java
│     │           │
│     │           ├─ service
│     │           │   └─ AnimalService.java
│     │           │
│     │           └─ AnimalShelterApplication.java
│     │
│     └─ resources
│        │
│        ├─ static
│        │   ├─ css
│        │   ├─ img
│        │   ├─ js
│        │   └─ index.html
│        │
│        ├─ templates
│        │   └─ animals
│        │       ├─ showAll.html
│        │       └─ add.html
│        │
│        └─ application.properties
│
└─ pom.xml
```

Controller nem beszél közvetlenül az adatbázissal.

Mindig:

Controller
↓
Service
↓
Repository
↓
Database

## Rendszer

index.html
↓
showAll.html
↓
JavaScript fetch()
↓
/api/animals
↓
Spring Boot REST API
↓
JSON
↓
HTML táblázat

## Postman

cmd-ben:
sudo apt update
sudo apt install snapd
sudo snap install core

sudo snap install postman

Elinditás cmd-ben:
postman

## Endpoints

http://localhost:8080/

http://localhost:8080/animals/view
http://localhost:8080/animals/add

Api:
http://localhost:8080/api/animals
http://localhost:8080/api/animals/11

# JUnit tesztek futtatásához

pom.xml fájlba ezt rakd bele a dependecies részre:

```bash
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

Menj a GitHub repository-dban a Settings -> Actions -> General -> 
Pipáld be ezt: Read and write permissions
-> Save

Menj a GitHub repository-dban a Settings -> Advanced Security -> Dependency graph -> Katt az Enable gombra.


## Online DB-vel való teszteléshez

### GitHub Secrets beállítása

Menj a GitHub repository-dban a Settings -> Secrets and variables -> Actions fülre.

Adj hozzá új "Repository secret"-eket a Render-en kapott adatok alapján:

Fontos, hogy a változóneveknek is egyezniük kell!

DB_URL: (Pl. jdbc:postgresql://dpg-xxx-a.frankfurt-postgres.render.com/mydb)

DB_USER: (A Render-en megadott user)

DB_PASS: (A Render-en kapott jelszó)

Az infókat a render.com-on láthatod a web service-en belül nyisd meg a projekted. -> Environment -> Environment Variables

### maven.yml

Ezt töröld ki:
```bash
    - name: Build with Maven
 ```

Ezt másold be:
```bash

            - name: Build and Test with Maven (Render DB)
              env:
        # Ezeket a GitHub Settings -> Secrets-nél kell megadnod!
                  DB_URL: ${{ secrets.DB_URL }}
                  DB_USER: ${{ secrets.DB_USER }}
                  DB_PASS: ${{ secrets.DB_PASS }}
```

Behúzások (Spaces): A YAML-ben nem használhatsz Tab-ot, csak szóközöket. 
A env: és a run: részeknek pontosan egy oszlopban kell lenniük a - name: kezdőbetűjével a fenti példa szerint.

Fontos, hogy a változóneveknek is egyezniük kell mindhárom helyen (application.properties, maven.yml, GitHub Secrets)!

### Engedélyezzük a db elérést

A render.com alapból letiltja, hogy a Github Actions hozzáférjen az adatbázishoz.
Nyisd meg a render.com-on az adatbázisod. -> Görgess lejebb a Networking részre. -> 
Ezeket írd be:
IP: 0.0.0.0/0
Description: GitHub Actions Access
-> Save gomb. -> Restart Database

GitHub-on az Actions részen a "Re-run jobs"-ra kattints.

Utána mehetnek ezek a terminálba:
mvn clean package
mvn test

## Offline H2 DB-s teszteléshez

Ha nem tudsz az online adatbázisodhoz csatlakoz, akkor használj H2 adatbázist a tesztekhez,
A test\resources mappába hozz létre egy: application.properties fájlt.

Ez legyen a tartalma:

```bash
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
```

pom.xml fájlba ezt másold be, ha még nincs benne:
```bash
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

## AnimalShelterApplicationTests.java fájl tartalmának módosítása

Ez a @TestPropertySource annotáció felülbírál minden fájlt. Teljesen mindegy, hogy hol van az application.properties, vagy hogy el van-e gépelve a mappa neve: a Spring ezeket az értékeket fogja használni a teszt alatt.

```java
package com.example.animal_shelter;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = {
		"spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1",
		"spring.datasource.driverClassName=org.h2.Driver",
		"spring.datasource.username=sa",
		"spring.datasource.password=",
		"spring.jpa.database-platform=org.hibernate.dialect.H2Dialect",
		"spring.jpa.hibernate.ddl-auto=create-drop",
		"spring.h2.console.enabled=false"
})
class AnimalShelterApplicationTests {

	@Test
	void contextLoads() {
		// Ez a teszt csak azt ellenőrzi, hogy elindul-e az alkalmazás
	}
}
```

Utána mehetnek ezek a terminálba:
mvn clean package
mvn test

# Local teszthez

mvn clean package

mvn test

mvn clean verify

# JUnit teszt kiírása a fő oldalra és készítése

README-be ezeket írd be:

![Build](https://github.com/USERNAME/REPO/actions/workflows/main.yml/badge.svg)
![Version](https://img.shields.io/github/v/release/USERNAME/REPO)
![License](https://img.shields.io/badge/license-MIT-green)

A badge csak akkor működik, ha van egy workflow fájlod itt:

.github/workflows/main.yml

Fájl tartalma:

```yml
name: Java CI with Maven # CI (Continuous Integration)

on: # Minden push és pull-ál lefut.
    push:
        branches: ["main"]
    pull_request:
        branches: ["main"]

jobs: # Maga a pipeline.
    build:
        runs-on: ubuntu-latest # Linux gépen fut.

        steps:
            - name: Checkout
              uses: actions/checkout@v4 # Kód letöltése.

            - name: Set up JDK 17 + cache
              uses: actions/setup-java@v4 #Java beállítása
              with:
                  java-version: "17"
                  distribution: "temurin"
                  cache: maven # Nem tölti le mindig újra a dependency-ket, sokkal gyorsabb a build.

            - name: Build & Test # CD (Continuous Deployment). Deploy a szerverre.
              run: mvn clean verify # Build + teszt. Lefordítja a projektet és lefuttatja a teszteket. +integrációs tesztek, lifecycle végigmegy
              # mvn clean test -> Build + teszt. Lefordítja a projektet és lefuttatja a teszteket.
```

A szóközök és a tabok fontosak, ha nincs jó helyen valami, akkor le se fog futni.

Ha megvan, akkor írd be ezt a terminálba: mvn clean verify
Ezzel le tudod csekkolni magad, hogy mit rontottál el.

## Release

Repo főoldalon jobb oldalt -> Releases panel → Create new

Tag version és Release title: v1.0.0

Katt a Generate release notes-ra.

## Tesztlefedettség ellenőrzése (jacoco)

A jacoco teszttel le lehet csekkolni, hogy a kód hány százaléka van letesztelve a JUnit tesztekkel.
Terminálban:  mvn clean verify
Itt láthatod az eredményt: target/site/jacoco/index.html -> Jobb klikk -> Live server.

A pom.xml fájlban a <plugins> részbe másold be ezt:

```xml
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.11</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>      
```

JaCoCo automatikusan lefut a build and test-kor. 

Letölthető lesz Githubról a teszt, ha a main.yml fájlbe ezt beírod:

```yml
            - name: Upload coverage
              uses: actions/upload-artifact@v4
              with:
                name: coverage-report
                path: target/site/jacoco
```
A szóközök és a tabok fontosak, ha nincs jó helyen valami, akkor le se fog futni.

<!-- TODO -->
A coverage badge-t a github-on a Codecov-al lehet megjeleníteni.
https://about.codecov.io/

# auto-squash 

<!-- TODO -->
Az auto-squash GitHubon (és Git-ben általában) arra való, hogy több commitot automatikusan összevonjon (squash) egyetlen tiszta commitba — főleg pull request (PR) előtt.

<!-- TODO -->
SonarQube automatikusan elemzi a kódot. Nagy segítséget nyújt a fejlesztésben és a tesztelésben.

# Online fejlesztéshez

[Github codenamespace](https://github.dev/)

Terminálban:
sdk install java 17.0.10-ms
mvn spring-boot:run 

export DB_URL='jdbc:postgresql://dpg-d69k87buibrs739i5fu0-a.frankfurt-postgres.render.com:5432/database_olpd'
export DB_USER='database_olpd_user'
export DB_PASS='sekoojWQ5YUGrgC3080avcnkVvgY4LSQ'
mvn spring-boot:run