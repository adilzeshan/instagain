require_relative './spec_helper'

describe User do
  before(:each) { User.auto_migrate! }
  let (:user){User.new(first: 'Kips',last: 'Davenport',user_name: 'xyz123')}

  context 'user details' do
    it 'should have a first name' do
      expect(user.first).to be_a String
    end
    it 'should have a last name' do
      expect(user.last).to be_an String
    end
    it 'should have a username' do
      expect(user.user_name).to be_an String
    end
    it 'should be able to change its name' do
      user.change_name('Adil Zeshan')
      expect(user.get_full_name).to eq "Adil Zeshan"
    end
  end

  context 'database' do
    it 'should be able to return all my images' do
      expect(get_user_photos("dp6ai")).to be_an Hash
    end
    xit 'should only be able to set a distinct username' do

    end
  end

  context 'followers' do
    it 'follow another user' do
      another_user = double :another_user
      user.follow another_user
    end
    it 'unfollow another user' do
      another_user = double :another_user
      user.unfollow another_user
    end
  end
end