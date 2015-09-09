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

For the paperclip library to function you will also need imagemagick installed.

To install it in OSX with homebrew you need to run:
```
$ brew install imagemagick
```

* Configuration

See the section called *Starting the server (development)*.

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
 the site be usable/testable. There are two versions, one from a more
 programatic source, and another which is closer to a rawd database dump.
```
$ rake db:seed
$ rake db:seed:raw
```

In Heroku to reset the database you need to run `heroku pg:reset DATABASE`.
 This command will drop and recreate your (now empty) database.

* Further Database initialization

If you need to start things from scratch, these commands can be useful:

```
$ rake db:reset
$ rake db:setup
### is the equivalent of:
$ rake db:drop db:create db:migrate db:seed
```

or to drop tables on heroku:
```
$ heroku pg:psql
---> Connecting to HEROKU_POSTGRESQL_AMBER_URL (DATABASE_URL)
psql (9.4.1, server 9.3.6)
SSL connection (protocol: TLSv1.2, cipher: DHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

still-coast-8321::AMBER=> \dt
(...)
still-coast-8321::AMBER=> select 'drop table "' || tablename || '" cascade;' from pg_tables WHERE tablename NOT LIKE 'pg_%' AND tablename NOT LIKE 'sql_%' ;
(...)
```

```
$ heroku run rake db:migrate
$ heroku run rake db:seed:raw
```

* Services (job queues, cache servers, search engines, etc.)

Only PostgreSQL >= 9.4 and ElasticSearch >= 1.6 for now.

In the future we will also have an support for varnish caching.

* Postgresql

Any version will probably sufice. In dev we are using the build from
 http://postgresapp.com/

* ElasticSearch (re)initialization

```
$ rails console
Ad.__elasticsearch__.delete_index!
Ad.__elasticsearch__.create_index!
Ad.published.import
```

If you are running it for the very first time, you probably dont need to
 delete the index. But it wont break anything if you do so.

Note: for large datasets, this could take a while. This should also be
 converted to a rake task.

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
  * PCONF_SMTP_ADDRESS  -- hostname of SMTP provider/server
  * PCONF_SMTP_USERNAME -- username for SMTP auth
  * PCONF_SMTP_PASSWORD -- password for SMTP auth

  * PCONF_* -- any variable that starts with PCONF is a plendit configuration.

  NOTE: HTTP AUTH is only enabled when running rails in production environment.

* How to run the test suite

Run:

```
$ bundle exec rspec --format=documentation
```
or just:
```
$ rspec
```

** Guard

To keep tests running constantly on the background, run guard:
```
$ bundle exec guard
```

** Testing payments

https://docs.mangopay.com/api-references/test-payment/

List av test bankkonto nummer:
```
15032080127
15032080135
15032080143
15032080151
15032080178
15032080186
15032080194
```

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

You will need to be logged in and to have the :site_admin role set in
your user. To do so:
```
$ rails console
(...)
2.1.5 :001 > User.find( :user_id ).add_role( :site_admin )
(...)
```

Where :user_id is the user_id of the user you'd like to be a site_admin.


* Image regeneration and format changes

If changing the different image styles that paperclip uses, run:

  rake paperclip:refresh:missing_styles

To regenerate thumbnail images run:

  rake paperclip:refresh:thumbnails CLASS=AdImage

Or all images with

rake paperclip:refresh CLASS=AdImage

* ...

Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.
