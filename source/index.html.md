---
title: EratoExpert API

language_tabs:
  - python: Python
  - objective_c: Objective-C

toc_footers:
  - <a href='http://developer.erato.hr'>Sign Up for a Developer Key</a>

includes:
  - errors

search: true
---
# EratoExpert API

EratoExpert API provides means to get *answers* and/or *actions* defined in [EratoExpert's web console](http://developer.erato.hr) based on your user's natural language query. 
Depending on your licence, you can define one or more EratoExpert projects in your web console. Each project gets its own EratoExpert execution server and each execution server provides API over SSL for consumers to use. 

EratoExpert API consumers will get up to top three results from EratoExpert execution server for specific project from a natural language query string.

# Authentication

EratoExpert execution server uses BasicAuth over SSL. You can define username and password for each project in EratoExpert's web console.

```objective_c
  // username and password value
  NSString *username = @"your_ee_server_username";
  NSString *password = @"your_ee_server_password";
  
  // HTTP Basic Authentication
  NSString *authString = [NSString stringWithFormat:@"%@:%@", username, password];
  NSData *authData = [authString dataUsingEncoding:NSASCIIStringEncoding];
  // Encoding data with base64 and converting back to NSString
  NSString* authStrData = [[NSString alloc] initWithData:[authData base64EncodedDataWithOptions:NSDataBase64Encoding76CharacterLineLength] encoding:NSASCIIStringEncoding];
  // Forming Basic Authorization string Header
  NSString *authValue = [NSString stringWithFormat:@"Basic %@", authStrData];
  
  // create URL request object
  NSMutableURLRequest *request = [
          [NSMutableURLRequest alloc] initWithURL: [
              NSURL URLWithString: [
                  NSString stringWithFormat:@"https://your-eratoexpert-server/?corpus=ACTIONS&query=%@", queryEscaped
              ]
          ]
      ];
  
  // Set your user login credentials to request
  [request setValue:authValue forHTTPHeaderField:@"Authorization"];
```

# Request

```python
  import requests

  result = None
  error = None

  try:
      req = requests.get(
          "https://your-eratoexpert-server/?query=your app user natural language query&corpus=KNOWLEDGE",
          auth=("username", "password"),  # BasicAuth
          verify=False  # if certificate is not authorized
      )
      result = req.json()
      if req.status_code != requests.codes.ok:
          error = req.status_code
  except requests.ConnectionError:
      error = _("ConnectionError")
  except:
      error = _("Unknown error, contact support!")
      traceback.print_tb(sys.exc_info()[3])
```

```objective_c
   __block NSDictionary *json;

  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
      if (data != Nil) {
          json = [NSJSONSerialization JSONObjectWithData:data
                                                options:0
                                                  error:nil];

          NSInteger returnCode = [[json valueForKey:@"return_code"] integerValue];
          NSString *returnCodeDescription = [json valueForKey:@"return_code_description"];
         
          if (returnCode == 0) {
             /* parse json and show answer / do action */
          }
          else {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EratoExpert API Error"
                                                             message:returnCodeDescription
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
     }
     
     if (connectionError != Nil) {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"EratoExpert server is not accessible."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
     }
  }];

```

Requests are made via HTTPS protocol to EratoExpert execution server (server:port) for each project you created in your EratoExpert's web console.

`GET https://<project's execution server>`

### Query Parameters

Parameter | Type    | Required | Description
--------- | ------- | -------- | -----------
query | string | true | Application user's natural language query
corpus | string | false | "ACTIONS" or "KNOWLEDGE" or empty. If empty, it will search both ACTIONS and Q&A part of the project.
action | string | false | Action code retrieved in previous EratoExpert call
missing | array[string] | false | Specific action variables that were missing in previous call 

# Response

> **Response JSON body for recognized ACTION**

> **duration** - number of milliseconds EratoExpert used for computing

> **certainy** - percentage of certainty that this answer/action is the correct one for provided query.


```json
{
    "return_code": 0,
    "duration": 76,
    "query": "Query provided in request",
    "query_type": "Corpus type from request, if provided. ACTION or empty for this example.",
    "top_answer": {
            "action": "ACTION CODE",
            "variables": {
                "VARIABLE_1": {"_final_": "Some recognized value"}
            },
            "variables-missing": ["list of variables missing for this action"],
            "certainty": 54.12,
            "type": "ACTION"
        },
    "answers": ["up to three JSON dictinaries, same as in top_answer attribute above"]
}
```
> **Response JSON body for recognized Q/A (KNOWLEDGE)**

> **answer** - new element, specific for KNOWLEDGE query type. No *action*, *variables* and *variables-missing* anymore.

```json
{
    "return_code": 0,
    "duration": 76,
    "query": "Query provided in request",
    "query_type": "Corpus type from request, if provided. KNOWLEDGE or empty for this example.",
    "top_answer": {
          "answer": "This is an answer for this project defined in Q&A section",
          "certainty": 54.12,
          "type": "ACTION"
        },
    "answers": ["up to three JSON dictinaries, same as in top_answer attribute above"]
}
```

Response body is in JSON format (application/json).

On the right, you can see two examples (well, combination of example and description) of response JSON. 
On the top is response with ACTION specific JSON attributes, and below it you can see response for Q&A (KNOWLEDGE) specific responses.

Main difference is that ACTION specific response has three attributes that are missing in other: `action`, `variables` and `variables-missing`.
On the other hand, KNOWLEDGE has `answer` attribute that is missing in actions. 

In case you got filled in "variables-missing" key in EratoExpert's response of this method, it means that some specific action was recognized but some of the variables defined for this action were not found in the query.
When you get such response, usually you will call this method again with "action" and "missing" request parameters filled in and EratoExpert will try to retrieve missing variables from new user's query provided in "query" parameter.

<aside class="warning">
Do not forget - if you do not set "corpus" parameter or you send it empty in the request, you can get mixed actions and knowledge answers. Be sure that that is the behavior you are expecting!
</aside>

## Action variables

In EratoExpert web console you can define actions and these actions can contain variables which you want retrieve in response. If variables are recognized by EratoExpert, they will be returned in response as populated values from natural language query. 

Action variables are returned as **JSON dictionary** with minimal set of `_final_` key containing final recognized value for this variable. If there are inner variables inside this variable, they will be inserted as additional keys in this dictionary.

<aside class="notice">
You can read details on how to define variables in your EratoExpert web console.
</aside>

Here are some examples.

### Example 1

> Action variables - Example 1

```json
{
  "variables": {
    "iznos": {
      "_final_": "200"      
  }
}
```

Most basic example is that for given action sentence with one variable, we define static values (or just type in case of number/date) as possible values for this variable.

`plati <iznos:"123"> eura`

Output is shown on the right side for the query sentence `Plaćanje 200 kuna`.

<aside class="notice">
Notice that string "123" after the variable name in action definition is not returned and is used only as an example of variable value. It is mandatory to define variable example as part of the whole action sentence in action definition. 
</aside>


### Example 2

> Action variables - Example 2

```json
{
  "variables": {
    "iznos_i_valuta": {
      "_final_": "200 HRK", 
      "iznos": {
        "_final_": "200"
      },
      "valuta": {
        "_final_": "HRK"
      }
    }
  }
}
```

On the other side, we might want to have currency returned as variable too, in case there can be more currencies in this action.
So, we can define action to contain inner variables too.

`plati <iznos_i_valuta:"123 eura">`

and variable `iznos_i_valuta` is further defined as:

`<iznos:"123"> <valuta:"eura">`, with *valuta* being defined as list of these values: ["HRK", "EUR"], and *iznos* as number type.

In case of request query being `plaćanje 200 kuna`, the JSON output for this action is on the right side.


### Example 3

> Action variables - Example 3

```json
{
  "variables": {
    "iznos_i_valuta": {
      "_final_": "200 HRK", 
      "iznos": {
        "_final_": "200"
      }
    }
  }
}
```

Another example - there can be some static string together with some variable inside a variable. So, starting with action sentence as:

`plati <iznos_i_valuta:"123 kuna">`

and variable `iznos_i_valuta` is this time defined as *iznos* variable (number type) together with static value "HRK":

`<iznos:"123"> HRK`

the output would be as shown on the right side, in case of request query being `plaćanje 200 kuna`.

<aside class="notice">
Notice that "HRK", as static value, is returned only as a part of "_final_" key of the main variable.
</aside>






