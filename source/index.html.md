---
title: Erato chatbot API

language_tabs:
  - json: JSON

toc_footers:
  - <a href='https://erato.hr'>Erato.hr</a>
  - <a href='https://blog.erato.hr'>Erato.hr BLOG</a>

includes:
  - errors

search: true
---
# Uvod

Erato API omogućuje da komunicirate sa svojim **objavljenim** chatbotom na [Erato chatbot platformi](https://erato.hr)! 
Nakon što objavite svoj chatbot, chatbot je dostupan na vlastitom URL-u (na vlastitoj poddomeni) i omogućuje API preko SSL-a.

# Autentifikacija

Chatbot API koristi [BasicAuth](https://en.wikipedia.org/wiki/Basic_access_authentication) za autentifikaciju pristupa. Nakon što objavite chatbot na stranici objave vidjet ćete generirano korisničko ime i lozinku.
To korisničko ime i lozinku trebate slati prilikom svakog API zahtjeva pomoću BasicAuth.

# API metode

Nekoliko je API metoda na raspolaganju za upravljanje vašim objavljenim chatbotom.

## /api/chat/config

> Primjer odgovora sa servera

```json
{
  "headerBackgroundColor":"#0089d0",
  "headerTextColor":"#ffffff",
  "language":"hr",
  "botIcon":"https://erato.hr/images/logo.png",
  "title":"EratoBot",
  "headerText":"EratoBot",
  "buttonIcon":"https://erato-eratobot-prod.api.expert.erato.hr/static-api/eratobot/img/2f1cd8c1-2fdb-4281-9c30-4ce71c9c5d15.png",
  "headerIcon":"https://erato-eratobot-prod.api.expert.erato.hr/static-api/eratobot/img/13aa4b51-111b-479f-9595-adda0297a096.png"
}
```

Pozivom ove metode dobit ćete konfiguraciju vašeg chatbota, onako kako ste to definirali na platformi (ikone, boje, thresholds, zadani tekstovi, ...).

API metoda | HTTP metoda    
--------- | ------- 
/api/chat/config | GET 

### Odgovor

JSON objekt konfiguracije.


## /api/chat/start

Pozivom ove metode dobit ćete elemente određene teme - defaultno teme "Dobrodošlica". Glavna svrha joj je inicijalno prikazivanje poruke korisnike prilikom prvog pokretanja chatbota. Može se upotrijebiti i za dohvat sadržaja bilo koje teme. Različitost od "message" metode je što ova metoda ne odgovara na neki korisnički upit, nego se direktno dohvaćaju elementi neke teme.

API metoda | HTTP metoda     
--------- | ------- 
/api/chat/start | GET(query parameters) / POST(json) 

### Zahtjev

Parametri/JSON struktura zahtjeva:

atribut | obavezno | default vrijednost | opis    
--------- | ------- | ------- | ------- 
uid | NE | autogenerating | Neki korisnički ID iz eksternog sustava koji jedinstveno identificira korisnika chatbota - ako takav podatak imate. Moći ćete pratiti analitiku prema korisniku.
sid | NE | autogenerating | ID sesije, definiran kako želite. Moći ćete pratiti analitiku prema sesijama.
topic | NE | Dobrodošlica | Ako želite pokrenuti neku drugu temu osim defaultne "Dobrodošlica", zadajte topic koje će biti identičan naslov neke teme vašeg chatbota.
variables-collected | NE | {} | varijable koje želite da chatbot ima na raspolaganju. JSON struktura, gdje je ime atributa *ime* varijable, a vrijednost je *vrijednost varijable*.

### Odgovor

JSON lista elemenata (JSON objekata) [odgovora](#elementi-chatbot-odgovora) chatbota.


## /api/chat/message

Ključna metoda za komunikaciju korisnika sa chatbotom. Pozivom ove metode dobit ćete odgovor(e) chatbota na korisnički upit.

API metoda | HTTP metoda     
--------- | ------- 
/api/chat/message | POST(json) 

### Zahtjev

> "messages" mora sadržavati povijest dijaloga korisnika i chatbota. Nije potrebno slati cijelu povijest, dovoljno je zadnjih 20 elemenata. VAŽNO je da JSON elementi u povijesti budu točno onakvi kakvi su inicijalno dobiveni sa servera, kronološki kako je tekao dijalog. Uz to, u povijest treba ubacivati i korisničke odgovore u obliku JSON objekta sa atributa "text", "link" i "value". 

> Niže je primjer korisničkog unosa odnosno JSON objekta koji treba biti u povijesti dijaloga, kao da je kliknuo gumbić "Kako si?" koji predstavlja link do druge teme.

```json
{
  "text": "Kako si?",
  "link": "1",
  "value": null
}
```

JSON struktura zahtjeva:

atribut | obavezno | default vrijednost | opis    
--------- | ------- | ------- | ------- 
uid | NE | autogenerating | Neki korisnički ID iz eksternog sustava koji jedinstveno identificira korisnika chatbota - ako takav podatak imate. Moći ćete pratiti analitiku prema korisniku.
sid | NE | autogenerating | ID sesije, definiran kako želite. Moći ćete pratiti analitiku prema sesijama.
text | link/value/text | - | Tekst upita koji je korisnik upisao / tekst buttona koji je korisnik kliknuo.
link | link/value/text | - | ID teme do koje vodi gumb koji je korisnik stisnuo (obavezno ako je korisnik kliknuo gumb koji vodi do neke teme - "internal_link")
value | link/value/text | - | Vrijednost koja je zadana u gumbu, ako je zadana ("value").
messages | DA | - | Povijest prepiske chatbota i korisnika, zadnjih 20 poruka. Točno onakva struktura kakva dobivena, kronološki (ASC), **uključujući i korisničke upite**.
variables-output | NE | {} | dodatne varijable koje želite da chatbot ima na raspolaganju. JSON struktura, gdje je ime atributa *ime* varijable, a vrijednost je *vrijednost varijable*.

<aside class="notice">
U zahtjevu prema serveru mora biti popunjen bar jedan od text/link/value!
</aside>

### Odgovor

JSON lista elemenata (JSON objekata) [odgovora](#elementi-chatbot-odgovora) chatbota.


## /api/chat/continue

Koristi se ako želite nastaviti eventualno nedovršeni dijalog. Ovisno o povijesti dijaloga (zadnji element u "messages" listi), u slučaju da postoji definirano još elemenata u temi koja se nalazi nakon elementa dobivenog na posljednjem mjestu u povijesti, vratit će nastavak dijaloga. 
Obično se ne koristi osim u kompleksnijim integracijama.

API metoda | HTTP metoda     
--------- | ------- 
/api/chat/continue | POST(json) 

### Zahtjev

JSON struktura zahtjeva:

atribut | obavezno | default vrijednost | opis    
--------- | ------- | ------- | ------- 
uid | NE | autogenerating | Neki korisnički ID iz eksternog sustava koji jedinstveno identificira korisnika chatbota - ako takav podatak imate. Moći ćete pratiti analitiku prema korisniku.
sid | NE | autogenerating | ID sesije, definiran kako želite. Moći ćete pratiti analitiku prema sesijama.
messages | DA | - | Povijest prepiske chatbota i korisnika, zadnjih 20 poruka. Točno onakva struktura kakva dobivena, kronološki (ASC), **uključujući i korisničke upite**.
variables-output | NE | {} | dodatne varijable koje želite da chatbot ima na raspolaganju. JSON struktura, gdje je ime atributa *ime* varijable, a vrijednost je *vrijednost varijable*.

### Odgovor

JSON lista elemenata (JSON objekata) [odgovora](#elementi-chatbot-odgovora) chatbota.


## /api/chat/rating

Korisničko ocjenjivanje chatbot odgovora.

API metoda | HTTP metoda     
--------- | ------- 
/api/chat/rating | POST(json) 

### Zahtjev

JSON struktura zahtjeva:

atribut | obavezno | default vrijednost | opis    
--------- | ------- | ------- | ------- 
uid | NE | autogenerating | Neki korisnički ID iz eksternog sustava koji jedinstveno identificira korisnika chatbota - ako takav podatak imate. Moći ćete pratiti analitiku prema korisniku.
sid | NE | autogenerating | ID sesije, definiran kako želite. Moći ćete pratiti analitiku prema sesijama.
messages | DA | - | Povijest prepiske chatbota i korisnika, zadnjih 20 poruka. Točno onakva struktura kakva dobivena, kronološki (ASC), **uključujući i korisničke upite**.
botResponse | DA | - | JSON objekt odgovora chatbota koji se ocjenjuje (jedan od JSON objekata iz "messages"). **Unutar njega treba ubaciti "rating" key sa ocjenom od 1 do 5.**

### Odgovor

JSON lista elemenata (JSON objekata) [odgovora](#elementi-chatbot-odgovora) chatbota.


# Elementi chatbot odgovora

Postoje nekoliko različitih vrsta elemenata koji predstavljaju sadržaj chatbot odgovora.

<aside class="notice">
JSON struktura pojedinog elementa dobivenog sa servera može, a najčešće i bude, sadržavala dodatne atribute u JSON objektu, osim onih koji su navedeni niže, a koji služe za interne potrebe. Njih se može ignorirati u klijentskim aplikacijama, ali nužno ih je sve vratiti prilikom slanja u povijesti dijaloga ("messages").
</aside>

## Tekst

> JSON schema

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "definitions": {},
  "properties": {
    "id": {
      "id": "/properties/id",
      "type": "string"
    },
    "text": {
      "id": "/properties/text",
      "type": "string"
    },
    "type": {
      "id": "/properties/type",
      "enum": [
        "text"
      ]
    },
    "buttons": {
      "id": "/properties/buttons",
      "items": {
        "id": "/properties/buttons/items",
        "properties": {
          "link": {
            "id": "/properties/buttons/items/properties/link",
            "type": "string"
          },
          "title": {
            "id": "/properties/buttons/items/properties/title",
            "type": "string"
          },
          "type": {
            "id": "/properties/buttons/items/properties/type",
            "enum": [
              "link_external",
              "link_internal"
            ]
          }
        },
        "required": [
          "type",
          "link",
          "title"
        ],
        "type": "object",
        "additionalProperties": true
      },
      "type": "array"
    }
  },
  "required": [
    "type",
    "text"
  ],
  "type": "object"
}
```

> Prvi element sa slike


```json
{
  "id": "1",
  "blockId": "1",
  "type": "text",
  "text": "Pozdrav! Dobrodošli na Erato.hr chatbot platformu! 🤖"
}
```

> Drugi element sa slike

```json
{
  "id": "1",
  "blockId": "1",
  "type": "text",
  "text": "Ja sam Erato chatbot i rado ću vam odgovoriti na sva pitanja! Možete odabrati ponuđena ili upisati svoje u polje na dnu.",
  "buttons": [
    {
      "id": 1,
      "title": "Što je Erato chatbot?",
      "type": "link_internal",
      "link": "3"
    },
    {
      "id": 2,
      "title": "Što je ustvari chatbot?",
      "type": "link_internal",
      "link": "4"
    },
    {
      "id": 3,
      "title": "Erato?",
      "type": "link_internal",
      "link": "5"
    }
  ]
}
```

Najćešći element komunikacije. Sadrži obavezni tekstualni dio odgovora i opcionalne gumbiće.
Niže su dva tekst elementa odgovora pri čemu jedan nema definiran, a drugi ima, opcionalne gumbiće.

atribut | vrijednost
--------- | ------- 
type | text

<img src="../images/elements/text.png" style="max-width: 300px">

JSON shema koja definira strukturu elementa, te primjeri strukture elemenata sa slike su vidljivi s desne strane. 
JSON objekte možete validirati prema JSON schemi na [https://www.jsonschemavalidator.net](https://www.jsonschemavalidator.net).

## Slika

> JSON schema

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "definitions": {},
  "properties": {
    "id": {
      "id": "/properties/id",
      "type": "string"
    },
    "type": {
      "id": "/properties/type",
      "enum": ["image"]
    },
    "url": {
      "id": "/properties/url",
      "type": "string",
      "pattern": "(http|https):\/\/.*"
    }
  },
  "required": [
    "url",
    "type",
    "id"
  ],
  "type": "object",
  "additionalProperties": true
}
```

> Primjer sa slike


```json
{
  "id": "1",
  "blockId": "2",
  "type": "image",
  "url": "https://erato.expert.erato.hr/static-api/erato-help-bot/img/204d07ac-790a-41db-9f97-6c9401b14f80.jpg"
}
```

Element pomoću kojeg prikazujemo sliku korisniku.

atribut | vrijednost
--------- | ------- 
type | image

<img src="../images/elements/image.png" style="max-width: 300px">

JSON shema koja definira strukturu elementa, te primjer strukture elemenata sa slike su vidljivi s desne strane. 
JSON objekte možete validirati prema JSON schemi na [https://www.jsonschemavalidator.net](https://www.jsonschemavalidator.net).

## Galerija



## Video

## Lista

## Gumbići

## API akcija