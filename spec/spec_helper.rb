# coding: utf-8
ENV['RAILS_ENV'] = ENV['RAKE_ENV'] = 'test'

$: << File.expand_path('../lib', __FILE__)

require 'pry'
require 'i19'

Dir['spec/support/**/*.rb'].each { |f| require "./#{f}" }

RSpec.configure do |config|
  include Fixtures
end
