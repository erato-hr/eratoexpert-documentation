# Greške

Erato API koristi sljedeće HTTP kodove grešaka:

> 400 Bad Request example JSON body

```json
{
    "return_code": -4,
    "return_code_str": "INVALID_PROJECT",
    "return_code_description": "Invalid PROJECT variable."
}
```

> 500 Internal Server Error JSON body

```json
{
    "return_code": -1,
    "return_code_str": "UNEXPECTED ERROR",
    "return_code_description": "There was an unexpected error. Message to administrators has been sent. Thank you for you patience!"
}
```

Kod | Značenje | Opis
---------- | ------- |--------------------------------------- 
400 | Bad Request | Your request sucks. Check if request body is application/json and see the error message.
401 | Unauthorized | Your BasicAuth username/password is wrong or not provided
500 | Internal Server Error | There was an unexpected error on the server side.
