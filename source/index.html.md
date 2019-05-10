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

> JSON schema

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "definitions": {},
  "properties": {
    "images": {
      "id": "/properties/images",
      "type": "array",
      "minItems": 1,
      "items": {
        "properties": {
          "url": {
            "id": "/properties/images/items/url",
            "type": "string"
          },
          "title": {
            "id": "/properties/images/items/title",
            "type": "string"
          },
          "subtitle": {
            "id": "/properties/images/items/subtitle",
            "type": "string"
          },
          "link": {
            "id": "/properties/images/items/link",
            "type": "string",
            "pattern": "(http|https):\/\/.*"
          },
          "buttons": {
            "id": "/properties/images/items/buttons",
            "items": {
              "id": "/properties/images/items/buttons/items",
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
              "minItems": 1,
              "required": [
                "type",
                "link",
                "title"
              ],
              "type": "object",
              "additionalProperties": true
            },
            "type": "array"
          },
        },
        "required": [
          "url",
          "title"
        ],
        "additionalProperties": true
      }
    },
    "id": {
      "id": "/properties/id"
    },
    "type": {
      "id": "/properties/type",
      "enum": [
        "gallery"
      ]
    }
  },
  "required": [
    "type",
    "images"
  ],
  "type": "object"
}
```

> Primjer JSON-a sa slike

```json
{
  "id": 24,
  "type": "gallery",
  "top_certainty": 100,
  "uid": "5e24074f1b9242f0b9cde8f07ca8cd04",
  "sid": "5e24074f1b9242f0b9cde8f07ca8cd04",
  "blockId": 3,
  "position": null,
  "images": [
    {
      "id": 1,
      "title": "Baka Crvenkapice",
      "subtitle": "Draga baka kojoj crvenkapica nosi košaricu s hranom!",
      "buttons": [],
      "url": "/static-api/erato-help-bot/img/4a45bf69-2b18-491f-a8bc-30337ccca8a0.jpg",
      "link": "http://crvenkapica.hr"
    },
    {
      "id": 2,
      "title": "Zločesti vuk",
      "subtitle": "Želi stići do bakice prije Crvenakapice!",
      "buttons": [],
      "url": "/static-api/erato-help-bot/img/1d080ba6-aafd-4df1-a833-12d957760156.jpg",
      "link": "http://crvenkapica.hr"
    }
  ],
  "timestamp": 1552317777.482227
}
```

Element pomoću kojeg prikazujemo galeriju slika korisniku.

atribut | vrijednost
--------- | ------- 
type | gallery

<img src="../images/elements/gallery.png" style="max-width: 300px">

JSON shema koja definira strukturu elementa, te primjeri strukture elemenata sa slike su vidljivi s desne strane. 
JSON objekte možete validirati prema JSON schemi na [https://www.jsonschemavalidator.net](https://www.jsonschemavalidator.net).

## Video

> JSON schema

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "definitions": {},
  "properties": {
    "id": {
      "id": "/properties/id"
    },
    "type": {
      "id": "/properties/type",
      "enum": ["video"]
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
  "id": 54,
  "blockId": 9,
  "position": 1,
  "uid": "5e24074f1b9242f0b9cde8f07ca8cd04",
  "sid": "5e24074f1b9242f0b9cde8f07ca8cd04",
  "type": "video",
  "url": "https://www.youtube.com/watch?v=02W4L3l6660",
  "timestamp": 1552319155.817773
}
```

Element pomoću kojeg prikazujemo video korisniku.

atribut | vrijednost
--------- | ------- 
type | video

<img src="../images/elements/video.png" style="max-width: 300px">

JSON shema koja definira strukturu elementa, te primjeri strukture elemenata sa slike su vidljivi s desne strane. 
JSON objekte možete validirati prema JSON schemi na [https://www.jsonschemavalidator.net](https://www.jsonschemavalidator.net).

## Lista

> JSON schema

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "definitions": {},
  "properties": {
    "header": {
      "id": "/properties/header",
      "type": "object",
      "properties": {
        "image": {
          "id": "/properties/header/properties/image",
          "type": "string",
          "pattern": "(http|https)://.*"
        },
        "title": {
          "id": "/properties/header/items/title",
          "type": "string"
        },
        "subtitle": {
          "id": "/properties/header/properties/subtitle",
          "type": "string"
        },
        "link": {
          "id": "/properties/header/properties/link",
          "type": "string",
          "pattern": "(http|https)://.*"
        },
        "button": {
          "id": "/properties/header/properties/button",
          "properties": {
            "link": {
              "id": "/properties/header/properties/button/properties/link",
              "type": "string"
            },
            "title": {
              "id": "/properties/header/properties/button/properties/title",
              "type": "string"
            },
            "type": {
              "id": "/properties/header/properties/button/properties/type",
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
        }
      },
      "allOf": [
        {
          "required": [
            "title"
          ],
          "anyOf": [
            {
              "required": [
                "subtitle"
              ]
            },
            {
              "required": [
                "button"
              ]
            },
            {
              "required": [
                "image"
              ]
            }
          ]
        }
      ],
      "additionalProperties": true
    },
    "elements": {
      "id": "/properties/elements",
      "type": "array",
      "minItems": 1,
      "maxItems": 4,
      "items": {
        "properties": {
          "image": {
            "id": "/properties/elements/items/image",
            "type": "string"
          },
          "title": {
            "id": "/properties/elements/items/title",
            "type": "string"
          },
          "subtitle": {
            "id": "/properties/elements/items/subtitle",
            "type": "string"
          },
          "link": {
            "id": "/properties/elements/items/link",
            "pattern": "(http|https)://.*"
          },
          "button": {
            "id": "/properties/elements/items/properties/button",
            "properties": {
              "link": {
                "id": "/properties/elements/items/properties/button/properties/link"
              },
              "title": {
                "id": "/properties/elements/items/properties/button/properties/title",
                "type": "string"
              },
              "type": {
                "id": "/properties/elements/items/properties/button/properties/type",
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
          }
        },
        "allOf": [
          {
            "required": [
              "title"
            ],
            "anyOf": [
              {
                "required": [
                  "subtitle"
                ]
              },
              {
                "required": [
                  "button"
                ]
              },
              {
                "required": [
                  "image"
                ]
              }
            ]
          }
        ],
        "additionalProperties": true
      }
    },
    "id": {
      "id": "/properties/id"
    },
    "type": {
      "id": "/properties/type",
      "enum": [
        "list"
      ]
    },
    "button": {
      "id": "/properties/button",
      "properties": {
        "link": {
          "id": "/properties/button/properties/link"
        },
        "title": {
          "id": "/properties/button/properties/title",
          "type": "string"
        },
        "type": {
          "id": "/properties/button/properties/type",
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
      "oneOf": [
        {"type": "null"},
        {"type": "object"}
      ],
      "additionalProperties": true
    }
  },
  "required": [
    "type",
    "elements"
  ],
  "type": "object"
}
```

> Primjer JSON-a sa slike

```json
{
  "id": 44,
  "type": "list",
  "uid": "5e24074f1b9242f0b9cde8f07ca8cd04",
  "timestamp": 1552318199.973706,
  "blockId": 7,
  "elements": [
    {
      "id": 1,
      "title": "Košara za baku",
      "subtitle": "Jabuke su fine!",
      "button": {
        "type": "link_internal",
        "isNew": false,
        "link": 9,
        "title": "Pogledaj video"
      },
      "image": "/static-api/erato-help-bot/img/61449db1-4b3a-4064-9030-f581a55bfe77.jpg",
      "link": "http://jabuke.hr"
    },
    {
      "id": 2,
      "title": "Cvijet za bakicu",
      "subtitle": "Lijepi crveni cvijet!",
      "button": {
        "type": "link_internal",
        "isNew": false,
        "link": 11,
        "title": "Pogledaj sliku"
      },
      "image": "/static-api/erato-help-bot/img/0be0b86e-6c9d-4f99-9e29-aea9072164e7.jpg",
      "link": "http://cvijet.hr"
    }
  ],
  "button": null,
  "position": 2,
  "sid": "5e24074f1b9242f0b9cde8f07ca8cd04"
}
```

Element pomoću kojeg prikazujemo listu korisniku.

atribut | vrijednost
--------- | ------- 
type | list

<img src="../images/elements/list.png" style="max-width: 300px">

JSON shema koja definira strukturu elementa, te primjeri strukture elemenata sa slike su vidljivi s desne strane. 
JSON objekte možete validirati prema JSON schemi na [https://www.jsonschemavalidator.net](https://www.jsonschemavalidator.net).

## Gumbići

> JSON schema

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "definitions": {},
  "type": "object",
  "properties": {
    "buttons": {
      "id": "/properties/buttons",
      "minItems": 1,
      "items": {
        "id": "/properties/buttons/items",
        "properties": {
          "id": {
            "id": "/properties/buttons/items/properties/id",
            "type": "integer"
          },
          "type": {
            "id": "/properties/buttons/items/properties/type",
            "enum": [
              "value",
              "link_internal",
              "link_external"
            ]
          },
          "link": {
            "id": "/properties/buttons/items/properties/link"
          },
          "title": {
            "id": "/properties/buttons/items/properties/title",
            "type": "string"
          },
          "value": {
            "id": "/properties/buttons/items/properties/value",
            "type": "string"
          }
        },
        "required": [
          "title"
        ],
        "type": "object",
        "additionalProperties": true
      },
      "type": "array"
    },
    "id": {
      "id": "/properties/id",
      "type": "integer"
    },
    "type": {
      "id": "/properties/type",
      "enum": [
        "buttons"
      ]
    },
    "variables": {
      "id": "/properties/variables",
      "type": "object",
      "patternProperties": {
        "^{{.*}}$": {
          "properties": {
            "type": {
              "id": "/properties/variables/type",
              "enum": ["list"]
            }
          },
          "required": [
            "type"
          ]
        }
      }
    }
  },
  "required": [
    "id",
    "type",
    "buttons"
  ]
}
```

> Primjer sa slike

```json
{
  "id": 63,
  "type": "buttons",
  "uid": "9845e828e859471ba393779409811422",
  "buttons": [
    {
      "id": 2,
      "type": "value",
      "isNew": false,
      "title": "Drugi put",
      "variables": {},
      "corpus": [],
      "link": "",
      "value": "Drugi put"
    },
    {
      "id": 1,
      "type": "link_internal",
      "isNew": false,
      "title": "Može, idemo!",
      "value": "Zvuči zanimljivo",
      "link": 10
    }
  ],
  "timestamp": 1552319809.464607,
  "variables": {},
  "blockId": 1,
  "corpus": [],
  "position": null,
  "sid": "9845e828e859471ba393779409811422"
}
```

Element pomoću kojeg prikazujemo horizontalne gumbiće korisniku.
Specifičnost ovog elementa je u tome da korisnik **mora** odbrati jedan od gumbića da bi nastavio dalje.


atribut | vrijednost
--------- | ------- 
type | buttons

<img src="../images/elements/buttons.png" style="max-width: 300px">

JSON shema koja definira strukturu elementa, te primjeri strukture elemenata sa slike su vidljivi s desne strane. 
JSON objekte možete validirati prema JSON schemi na [https://www.jsonschemavalidator.net](https://www.jsonschemavalidator.net).

## API akcija

> JSON schema

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "definitions": {},
  "properties": {
    "id": {
      "id": "/properties/id"
    },
    "type": {
      "id": "/properties/type",
      "enum": ["api_action"]
    },
    "action": {
      "id": "/properties/action",
      "type": "string"
    }
  },
  "required": [
    "action",
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
  "id": 88,
  "blockId": 16,
  "uid": "d5ed9945637342b5a9c406bc66a07fd5",
  "sid": "d5ed9945637342b5a9c406bc66a07fd5",
  "type": "api_action",
  "action": "SERVERSKA_AKCIJA_1",
  "variables-input": {
    "iznos": "100"
  },
  "timestamp": 1552319660.077679,
}
```

Api akcija u principu ne služi za prikaz sadržaja korisniku, već se koristi kao oznaka onome tko koristi Erato API da je potrebno nešto učiniti u tom trenutku, obično odraditi neku akciju na serveru.
U tom elementu je kroz sučelje moguće je proslijediti jednu ili više varijabli dobivenih ranije u dijalogu, a koja se može koristiti za izvršenje neke akcije na serveru.

Također, moguće je definirati opcionalne izlazne varijable koje će ta API akcija vratiti nazad u dijalog. Vraćanje varijable natrag u dijalog radi se tako da nakon što vanjski sustav izvrši željenu API akciju i dobije vrijednosti koje želi spremiti u varijablu, pozove Erato API metodu [continue](#api-chat-continue) u kojoj će popuniti parametar `varijables-output`, a u `messages` treba poslati povijest koja na posljednjem mjestu sadrži taj dobiveni element API akcije. Ta će metoda tada vratiti nastavak dijalog od tog elementa.

atribut | vrijednost
--------- | ------- 
type | api_action

<img src="../images/elements/api_action.png" style="width: 100%">

JSON shema koja definira strukturu elementa, te primjeri strukture elemenata sa slike su vidljivi s desne strane. 
JSON objekte možete validirati prema JSON schemi na [https://www.jsonschemavalidator.net](https://www.jsonschemavalidator.net).