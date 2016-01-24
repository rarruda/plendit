
## Generic testing information

### Testing payments

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

## RSpec

### How to run the test suite

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

### Factorygirl

To test rspec/factorygirl from console:
```
rails console test --sandbox
```

  * http://stackoverflow.com/questions/18195851/how-do-i-use-factories-from-factorygirl-in-rails-console


### Guard

To keep tests running constantly on the background, run guard:
```
$ bundle exec guard
```

By having it running, it will be much faster at running the tests then
 starting it manually. (Uses spring as an application preloader).


## Capybara

Capybara integration tests are found in `spec/features`

To run it:
```
bundle exec rspec spec/features/search_ad_spec.rb
```

It will run the tests in a firefox window.
NOTE: You still need to type the HTTPAuth credentials on each run.

 More info in the official github repo:

  * https://github.com/jnicklas/capybara