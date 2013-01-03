source "http://rubygems.org"

gem "celluloid"
gem "celluloid-io"

gem 'sequel'

gem 'activesupport'

platforms :ruby do
  gem 'pg'
end

# JRuby
platforms :jruby do
  gem 'jruby-openssl'
  gem 'jdbc-postgres', require: 'jdbc/postgres'
end