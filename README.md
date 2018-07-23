
## Purpose

Simple demo of a `Browser.application` which can
respond to urls like `http://localhost:8080/WHATEVER`,
where `WHATEVER` (which can be empty), and the app
tries to parse into a value of type `UrlData`:

```
    type UrlData = 
      PublicQuery String 
    | PrivateQuery String 
    | NumericalDocumentID Int 
    | DocumentUUID String 
```

For example, 

  1. loading the app manually with `http://locahost:8080`
     is successful but creates no `UrlData` value.

  2. Loading the app manually with `http://locahost:8080/api/document/123`
     is successful and creates the `UrlData` value `NumericalDocumentId 123`.

## Setup

Set up `nginx` with  (`brew install nginx` on mac os).
Copy the supplied `nginx.conf` to `/usr/local/etc/nginx/nginx.conf`.

Use elm 0.19 for compilation.  Edit `make.sh` so 
that you are using the right compiler binary.  You 
will have to change `Users/carlson/Downloads/2/elm`
to be compatible with your local setup.

Use `sh make.sh -i` to compile to `Main.js` 
and use the supplied `index.html` file.

## Testing

The app boots up with some links that you can click on for testing.

### Further examples

`http://localhost:8080/api/document/jxxcarlson.foobar` will
result in `UUID: jxxxcarlson.foobar`.


`http://localhost:8080/api/documents/foo=bar` will
result in `Private query: foo=bar`.

`http://localhost:8080/api/public/documents/foo=bar` will
result in `Public query: foo=bar`.

