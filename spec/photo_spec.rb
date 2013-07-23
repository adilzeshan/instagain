require_relative  '../instagain.rb'

describe Photo do

	let(:photo) {Photo.create(name: 'Holidaypic', url: 'public/pics/test.jpg')}

	it 'photo has a name' do
		expect(photo.name).to eq 'Holidaypic'
	end

	it 'photo has a location' do
		expect(photo.url).to eq 'public/pics/test.jpg'
	end

	it 'can have name changed'  do
		photo.change_name 'Holiday2'
		expect(photo.name).to eq 'Holiday2'
	end

end