require 'capybara'
require 'capybara/dsl'
require_relative '../spec_helper'

Capybara.app = AuthenticationApp

RSpec.configure do |config|
  config.include Capybara
end