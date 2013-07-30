require_relative './spec_helper'

describe Photo do

	let(:photo) {Photo.create(name: 'Holidaypic', url: 'public/pics/test.jpg')}

	xit 'photo has a name' do
		expect(photo.name).to eq 'Holidaypic'
	end

	xit 'photo has a location' do
		expect(photo.url).to eq 'public/pics/test.jpg'
	end

	xit 'can have name changed'  do
		photo.change_name 'Holiday2'
		expect(photo.name).to eq 'Holiday2'
	end

end