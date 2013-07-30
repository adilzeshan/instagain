require 'capybara'
require 'capybara/dsl'
require_relative '../spec_helper'
require_relative '../../instagain'

Capybara.app = Instagain

RSpec.configure do |config|
  config.include Capybara::DSL
end

DataMapper.auto_upgrade!