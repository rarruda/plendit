== README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

We use ruby 2.1. To install the correct ruby version first install rvm and then ruby:

```bash
### Download and install rvm in your home directory: (in ~/.rvm)
$ \curl -sSL https://get.rvm.io | bash -s stable
### Then load RVM in your shell: (and all other open terminals you might want to
# use RVM on)
$ source ~/.rvm/scripts/rvm
### Install correct version of ruby:
$ rvm install ruby-2.1.5 -v
```

* System dependencies

We need a few gems to run. To install these gems first go to the same path as
 this file is at (root of the project) and run:
```
$ gem install bundler
$ bundle install
```

This will read Gemfile/Gemfile.lock, resolve all dependencies and install
 all gems correctly.

* Configuration

There is currently no special configuration needed to get the application running.

* Database creation

```
$ rake db:create
```

* Database initialization

Initialize schema

```
$ rake db:migrate
```

Load seed data:
That is, add just enough test data so its possible to play around and
 the site be usable/testable.
```
$ rake db:seed
```

In Heroku to reset the database you need to run `heroku pg:reset DATABASE`.
 This command will drop and recreate your (now empty) database.

* Starting the server (development)

```
$ rails server
### or a shorthand for the command:
$ rails s
```

You can then point your browser to localhost:3000 and see the app in action.

Note: the server is smart enough so that you never need to restart it for any
 changes in the filesystem to take effect. So, no need for restarts when
 developing.

* ENV variables that should be set on start up the rails server

  * PCONF_HTTP_AUTH_USERNAME -- username for HTTP authentication. To protect site
     from casual passer bys.
  * PCONF_HTTP_AUTH_PASSWORD -- "" ""
  * PCONF_FACEBOOK_APP_ID -- for enabling federated authentication
  * PCONF_FACEBOOK_SECRET -- "" ""

  NOTE: HTTP AUTH is only enabled when running rails in production environment.

* How to run the test suite

No tests are currently available.

* Services (job queues, cache servers, search engines, etc.)

None for now.

* Deployment instructions

Will probably be deployed via capistrano. For now, there is no deployment.

* Generating Model and Controller UML diagrams

Using railroady: ( https://github.com/preston/railroady )
```
$ bundle exec rake diagram:all
```

SVG images will be then available at doc/

or using ERD ( https://github.com/voormedia/rails-erd ):
```
bundle exec erd --filename=doc/erd
```

The UML diagram will then be available as a pdf file at doc/erd.pdf

* Admin UI

To access the admin interface go to http://localhost:3000/admin/

To create an admin account first start the rails console, then
 run the create command as follows:
```
$ rails console
(...)
2.1.5 :001 > AdminUser.create!(:email => 'admin@example.com', \
  :password => 'password', :password_confirmation => 'password')
(...)
```

This is also how the default admin user is created by default.

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.
