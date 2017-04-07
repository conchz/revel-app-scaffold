# revel-app-scaffold

A scaffold of [*revel*](https://github.com/revel/revel)(A high-productivity web framework for the **Golang**).

### Start the web server:

   ``` revel run github.com/lavenderx/revel-app-scaffold ```

### Go to http://localhost:9000/ and you'll see:

    "It works"

## Code Layout

The directory structure of a generated Revel application:

    conf/             Configuration directory
        app.conf      Main app configuration file
        routes        Routes definition file

    app/              App sources
        init.go       Interceptor registration
        controllers/  App controllers go here
        views/        Templates directory

    messages/         Message files

    public/           Public static assets
        css/          CSS files
        js/           Javascript files
        images/       Image files

    tests/            Test suites
    
## Deploying to Heroku

Make sure you have [Go](https://golang.org/doc/install) and the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) installed.

    ```sh
    $ heroku create -b https://github.com/revel/heroku-buildpack-go-revel.git
    $ git push heroku master
    $ heroku open
    ```
    or
    
    [![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Documentation

* The [Getting Started with Revel](http://revel.github.io/tutorial/gettingstarted.html).
* The [Revel guides](http://revel.github.io/manual/index.html).
* The [Revel sample apps](http://revel.github.io/examples/index.html).
* The [API documentation](https://godoc.org/github.com/revel/revel).
* The [Revel Chinese Community](http://gorevel.cn).
* The [Go on Heroku](https://devcenter.heroku.com/categories/go).
