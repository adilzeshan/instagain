require 'capybara'
require 'capybara/dsl'
require_relative '../spec_helper'
require_relative '../../instagain'

Capybara.app = Instagain

RSpec.configure do |config|
  config.include Capybara::DSL
end

def signin username, password
  visit '/signin'
  within('.form-signin') do
    fill_in 'User name', :with => username
    fill_in 'password', :with => password
    click_on 'Login'
  end
end