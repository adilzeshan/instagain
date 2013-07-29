require_relative './acceptance_spec_helper'

describe User do
  
  before(:each) do
    User.create(first: 'Kips',last: 'Davenport',user_name: 'xyz123', password: 'letmein')
  end
  
  context "login page" do
    
    it "should allow users to login" do
      signin('xyz123', 'letmein')
      expect(page).to have_css("h4", text: "Hi, Kips Davenport")
    end
    
  end
  
end
