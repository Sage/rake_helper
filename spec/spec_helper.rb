require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'
end

require 'rspec'
require 'pry'
require 'rails'
require 'active_record'
require 'rake_helper'

Rails.logger = Logger.new(File.join('spec', 'log', 'test.log'))
