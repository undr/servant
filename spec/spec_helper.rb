$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'servant'
require 'rspec/its'
require 'rspec/collection_matchers'

Dir['./spec/supports/**/*.rb'].each { |f| require f }
