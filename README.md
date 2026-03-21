![Build](https://github.com/Nagraggini/animal-shelter/actions/workflows/main.yml/badge.svg)
![Version](https://img.shields.io/github/v/release/Nagraggini/animal-shelter)
![License](https://img.shields.io/badge/license-MIT-green)

# Animal Shelter Web Application

This is a simple Spring Boot web application that uses Thymeleaf templates and an embedded PostgreSQL database.

The goal of this project is to demonstrate how to build a dynamic web application using Spring Boot and to make it deployable with Docker on Render.com.

## Short description

This web application is an administrative interface for an animal shelter, providing functionality to list animals and to record new animal data.

[Visit my site!](https://animal-shelter-hro5.onrender.com/)

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
```

# I used:

## Backend (Server-side)

- Spring Boot application (AnimalShelterApplication.java)
- Controller classes, e.g., AnimalsController (if present), handling requests like /login, /register, etc.
- Model classes, e.g., User, Product, representing the data.
- PostgreSQL+ JPA repositories for storing and querying data.
- ORM: Hibernate (JPA)
- Business logic, e.g., checking user.name values or saving users.

## Frontend (User Interface)

- HTML templates (.html files in resources/templates)
- Thymeleaf attributes, e.g., th:text, th:case, for dynamically rendering data from the backend.
- CSS / Tailwind for styling.
- JavaScript for interactivity.

# Structure

Frontend (HTML + Thymeleaf)  
│  
▼  
Spring Controller  
│  
▼  
Controller (Business Logic)  
│  
▼  
PostgreSQL Database (data)

## Local running

### Maven

```bash
./mvnw clean spring-boot:run
```

### Run with Docker

```bash
docker build -t animal_shelter .
docker run -p 8080:8080 animal_shelter
```

## Endpoints

| Endpoint           | Method | Description                                |
| ------------------ | ------ | ------------------------------------------ |
| `/`                | GET    | Index – start of the website               |
| `/add.html`        | GET    | Display form to add a new animal           |
| `/animals/view`    | GET    | List all animals (`showAll.html` template) |
| `/animals/view`    | POST   | Add a new animal (process form submission) |
| `/actuator/health` | GET    | Health check endpoint (Spring Actuator)    |

# Technologies

- Java 17
- Spring Boot
- Thymeleaf
- PostgreSQL Database
- Docker

[I did it based on that.](https://www.youtube.com/watch?v=RK6aAjUMcl0&list=PLg7lel5LdVjyO7jk-4biyr0fqPVygTLOk)

[Repository for the above youtube video.](https://github.com/bobbychansfu/springboot-render/tree/7d38d0343465661adceb6372591a8353717dfd5e)

## ///////////////////////////////////////////////////////////////////////////////////

Hungarian version - Magyar verzió

# Menhely webalkalmazás

Ez egy egyszerű Spring Boot webalkalmazás, ami Thymeleaf sablonokat és beágyazott PostgreSQL adatbázist használ.

A projektem célja, hogy bemutassa a dinamikus webalkalmazás készítését Spring Boot-tal, és hogy deploy-olható legyen Dockerrel Render.com-on.

Rövid leírás

Ez a webalkalmazás egy állatmenhely adminisztrációs felülete, amely biztosítja az állatok listázását és új állatok adatainak rögzítését.

[Látogasd meg az oldalam!](https://animal-shelter-hro5.onrender.com/)

# Amit használtam:

## Backend (Szerveroldal)

- Spring Boot alkalmazás (AnimalShelterApplication.java)
- Controller osztályok, pl. AnimalsController, amelyek kezelik a kéréseket (/login, /register stb.)
- Model osztályok, pl. User, Product, amelyek az adatokat reprezentálják
- PostgreSQL adatbázis + JPA repository-k az adatok tárolásához és lekérdezéséhez
- ORM: Hibernate (JPA)
- Üzleti logika, pl. user.name értékek ellenőrzése vagy felhasználók mentése

## Frontend (Felhasználói felület)

- HTML sablonok (.html fájlok a resources/templates mappában)
- Thymeleaf attribútumok, pl. th:text, th:case, az adatok dinamikus megjelenítéséhez a backendből
- CSS / Tailwind a megjelenés formázásához
- JavaScript az interaktivitáshoz

# Felépítés

Frontend (HTML + Thymeleaf)  
│  
▼  
Spring Controller  
│  
▼  
Controller (Üzleti logika)
│  
▼  
PostgreSQL adatbázis (adatok)

[Itt találod a részletes leírást, mit és hogyan csináltam.](https://github.com/Nagraggini/animal_shelter/blob/main/HowToDoIt_Hungarian_version.md)
