require_relative './acceptance_spec_helper'

describe 'the signin process' do
  before :all do
    User.create(
                    first:      'Patrick',
                    last:       'Davenport',
                    user_name:  'username',
                    email:      'user@example.com',
                    password:   'password'
                )
   User.create(
                    first:      'Dave',
                    last:       'Smith',
                    user_name:  'username2',
                    email:      'user2@example.com',
                    password:   'password'
                )
  end

  def login
    visit '/signin'
      within('.form-signin') do
        fill_in 'user_name', :with => 'username'
        fill_in 'password', :with => 'password'
        click_button 'Login'
      end
  end

  context 'login page' do
    it 'signs me in' do
      login
      expect(page).to have_content 'Hi, Patrick Davenport'
    end
  end

  context 'profile page' do
    it 'shows non followed users' do
      login
      visit '/profile'
      #puts page.html
      find('#templist').find('li').should have_content('username2')
    end
  end

end
