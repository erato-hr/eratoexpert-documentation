# Errors

EratoExpert API uses the following error codes:

> 400 Bad Request example JSON body

```json
{
    "return_code": -1,
    "return_code_str": "QUESTION_MISSING",
    "return_code_description": "Missing QUESTION in request"
}
```

Error Code | Meaning
---------- | -------
400 | Bad Request -- Your request sucks. Check if request body is application/json and see the error message.
401 | Unauthorized -- Your BasicAuth username/password is wrong or not provided
