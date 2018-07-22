## Purpose

(1) Try to get an app usig `Browser.application` working
with a user-supplied `index.html` file and (2) make
it work properly on manual reload with a modified 
url as desribed in **Testing** below.  Briefly,
things are working when compiling with `elm make Main2.elm`
but not with `elm make Main2.elm --output Main.js` with 
the supplied `index.html` file.

To work properly, the app must be served with a web server
configured to return the app with url `http://localhost:8080/WHATEVER`,
where `WHATEVER` may or may not be empty.

NOTE: this is written for tag V1.0.1

## Setup

Set up `nginx` with  (`brew install nginx` on mac os).
Copy the supplied `nginx.conf` to `/usr/local/etc/nginx/nginx.conf`.

Use elm 0.19 for compilation.  Edit `make.sh` so 
that you are using the right compiler binary.  You 
will have to change `Users/carlson/Downloads/2/elm`
to be compatible with your local setup.

(1) Use `sh make.sh -s` to compile the app using
`elm make`.  The script will copy the resulting
`index.html` file to `/usr/local/var/www/`
and will run `nginx` so as to serve the 
app at `http://localhost:8080`

(2) Use `sh make.sh -i` to compile to `Main.js` 
and use the supplied `index.html` file.
As before, the app will be served
at `http://localhost:8080`

## Testing

In both cases, the app will function at `http://locahost:8080`.
However, in case (1), manually loading `http://localhost:8080/public/doc/123`
will load the app *and will also result in the app parsing the
url path to `Numerical ID = 123`.* Likewise, loading
`http://localhost:8080/public/doc/jxxcarlson.foobar` will
result in `UUID = jxxxcarlson.foobar`.

In the case of (2), both of the just-described experiments will 
fail.  I don't know how to fix this.