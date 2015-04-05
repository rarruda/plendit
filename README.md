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

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.
