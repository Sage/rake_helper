# rake_helper

[ ![Codeship Status for dchopson/rake_helper](https://codeship.com/projects/4243c0e0-3a79-0134-4812-3e7f3bc4dc3e/status?branch=master)](https://codeship.com/projects/166332) [![Gem Version](https://badge.fury.io/rb/rake_helper.svg)](https://badge.fury.io/rb/rake_helper)

A set of common helper methods to DRY up Rails rake tasks

## Installation

Add to your project's Gemfile:
```ruby
gem 'rake_helper'
```

Run:
```
bundle install
```

Include in your project's Rakefile:
```ruby
include RakeHelper
```

## Usage

### Logging Messages

These output a timestamped `puts` statement in the terminal for the benefit 
of the person running the rake task, but also log a message in the Rails 
log in case it is missed in a long stream of output.

There are 3 predefined methods which prepend a standardized keyword:

#### start
Logs as type `:info`
```ruby
start('Updating user records')
# => 2016-08-07 13:02:51 -0400 START: Updating user records
```

#### finish
Logs as type `:info`
```ruby
finish('Updating user records')
# => 2016-08-07 13:04:28 -0400 FINISH: Updating user records
```

#### failure
Logs as type `:error`
```ruby
failure("Updating user records: #{e}")
# => 2016-08-07 13:03:16 -0400 FAILURE: Updating user records: SomeError
```

The standard logger severities can also be called directly as methods with a
single `message` parameter:
* `warn`
* `unknown`
* `info`
* `fatal`
* `debug`
* `error`

For example: 
```ruby
info('Useful information')
# => 2016-08-07 13:03:16 -0400 Useful information
```

### Running SQL Statements

The `run_sql` method will execute one or more SQL statements and return the
results as an `Array`. The first param is required and should be a valid SQL
string. The string can include several statements separated by semicolons.
You can pass an `action` option which should be any valid
[ActiveRecord::ConnectionAdapters::DatabaseStatements](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html)
method name as a symbol.

#### :update example
```ruby
sql = <<-SQL
  UPDATE users SET activated = 1 WHERE created_at > 2016-01-01;
  UPDATE businesses SET name = 'Widgets Inc' WHERE id = 22; 
SQL

run_sql(sql)

# OR capturing the record count for each query:

results = run_sql(sql, action: :update)
info("User count: #{results.first}, Business count: #{results.last}")
# => 2016-08-07 13:11:45 -0400 "User count: 10, Business count: 1"
```

#### :select_value example
```ruby
sql = <<-SQL
  SELECT id FROM users WHERE email = 'bob@example.com'; 
SQL

results = run_sql(sql, action: :select_value)
info("Bob's ID: #{results.first}")
# => 2016-08-07 13:11:45 -0400 "Bob's ID: 15"
```

#### :delete example
```ruby
sql = <<-SQL
  DELETE FROM users WHERE created_at < 2016-01-01 AND activated = 0; 
SQL

run_sql(sql)

# OR capturing the record count for each query:

results = run_sql(sql, action: :delete)
info("Num users deleted: #{results.first}")
# => 2016-08-07 13:11:45 -0400 "Num users deleted: 52" 
```

### Full Example

#### Rake File
```ruby
# lib/tasks/update_locales.rake

desc 'Update US locales to en-US'
task update_locales: :environment do
  message = 'Updating US locales'
  start(message)

  sql = <<-SQL
    UPDATE users SET locale = 'en-US' WHERE locale IS NULL OR locale = 'en';
    UPDATE countries SET locale = 'en-US' where code = 'US';
  SQL

  begin
    run_sql(sql)
    finish(message)
  rescue Exception => e
    failure(e)
  end
end
```

#### Successful Run
```sh
$ bundle exec rake update_locales
2016-08-07 13:57:56 -0400 START: Updating US locales
2016-08-07 13:57:56 -0400 FINISH: Updating US locales
```

#### Failed Run
```sh
$ bundle exec rake update_locales
2016-08-07 14:07:50 -0400 START: Updating US locales
2016-08-07 14:07:50 -0400 FAILURE: ActiveRecord::ConnectionTimeoutError
```
