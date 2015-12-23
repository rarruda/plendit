== README

This README would normally document whatever steps are necessary to get the
application up and running.

The steps needed are described in detail below. Roughly, setup consis of:

- Install postgres.app and start it
- Install elasticsearch and start it
- Install redis and start it
- Check out the code
- Install ruby
- Install ruby gems the project depends on
- Run rake task to create database
- Run rake task to run database migrations
- Run rake task to load sample user data
- Run rails console and run elasticsearch related commands

At this point you should be able to start the server with `bundle exec passenger start`.

Using `rails s` should still work, but not if you want to use passenger
  (as we do in production). For more information about passenger take a look at:
  https://www.phusionpassenger.com/library/walkthroughs/start/ruby.html#no-bundle-exec-rails-server-yet


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

Only PostgreSQL >= 9.4, Redis >= 3.0 and ElasticSearch >= 1.6 for now.

In the future we will also have an support for varnish caching.

* Postgresql

Any version will probably sufice. The simplest way to install this for mac
users is probably to use http://postgresapp.com/ . The homebrew version is
also a possiblity

* Redis

We have only tested with Redis >= 3.0. Other versions could work. For development
 you can just download the precompiled tarball from http://redis.io/.
 Homebrew does not have redis 3.0 yet. (though it could still work with an older
 version of redis).

To start: (after unpacking the tarball)
`./src/redis-server`

* Resque worker

To get the job from any queue and do the work, run the following command.

```
rake resque:work QUEUE='*'
```

This command helps to test background jobs in development environment. For production:
```
rake production resque:work QUEUE='*'
```

To see the status of the reque queues, its possible to use the dashboard at:

`http://localhost:3000/internal-backstage/resque-web/`

NOTE: It is recommended that a production deployment of resque-scheduler be hosted on
 a dedicated Redis database. This is because it uses the KEYS command in redis which
 is O(N), but must transverse all keys in the keyspace.
 FROM: https://github.com/resque/resque-scheduler#deployment-notes

* Resque scheduler

Can be started with this command:
```
bundle exec rake <environment> resque:scheduler --trace
```

It will then generate jobs according to the configuration in cron settings.

* ElasticSearch (re)initialization

Install elasticsearch. Mac uses can use the version from homebrew:

`brew install elasticsearch`

You can then start elasticsearch in a terminal with the `elasticsearch` command.

Note, homebrew will also explain how to make elasticsearch start automatically.
You can do that if you prefer.

To index (or re-index) ElasticSearch:
```
$ rake search:reindex
```

There is also a capistrano command which triggers the same rake task for reindexing:
 (but in production).
```
$ cap production search:reindex
```


The manual commands to index, slowly are (one ad at a time):
```
$ rails console
Ad.__elasticsearch__.delete_index!
Ad.__elasticsearch__.create_index!
Ad.published.import
```

If you are running it for the very first time, you probably dont need to
 delete the index. But it wont break anything if you do so.

Note: for large datasets, this could take a while. So prefer to use the rake
 task, which perform bulk operations, which is much faster.

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

To run rails console against the test environment:
```
bundle exec rails c test
```

And rake tasks agains the test environment:
```
rake ... RAILS_ENV=test
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

To deploy to beta:
```
bundle exec cap production deploy
```

To deploy to dev:
```
bundle exec cap development deploy
```

* Checking application status

Go to the following URL for a health-check overview of the application and
  its requirement statuses:

`http://localhost:3000/internal-backstage/health-check/all.json`

For checking that the application is up:
`http://localhost:3000/internal-backstage/health-check/`

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

To access the admin interface go to http://localhost:3000/internal-backstage/admin/

You will need to be logged in and to have the :site_admin role set in
your user. To do so:
```
$ rails console
(...)
2.1.5 :001 > User.find( :user_id ).add_role( :site_admin )
(...)
```

Where :user_id is the user_id of the user you'd like to be a site_admin.

* Code style

Here are code style guidelines which we call recommended reading:
https://github.com/bbatsov/rails-style-guide
https://github.com/bbatsov/ruby-style-guide

For automatically checking the compliance to the standard, use rubocop:
https://github.com/bbatsov/rubocop

For integrating it with sublime text:
https://github.com/pderichs/sublime_rubocop

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


* Encoding videos and frames for frontpage

Videos should be in mp4 and webp format. There also needs to be
an initial fram image to be used on mobile and while the video
loads. The followign encodes an m2v to the right formats ands
extracts the first frame as a jpg. Note, the "750K" value can
be tweaked to get higher quality at the expense of larger files.

```
ffmpeg -i baatliv_04.m2v -movflags +faststart -c:v libx264 -preset slow -an -b:v 750K  baatliv_4.mp4
ffmpeg -i baatliv_04.m2v -c:v libvpx -preset slow -s 1024x576 -qmin 0 -qmax 50 -an -b:v 750K baatliv_4.webm
ffmpeg -i baatliv_04.m2v -vframes 1 -f image2 baatliv_4.jpg
```

