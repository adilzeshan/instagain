require 'filter'

describe Filter do
  let(:image){Filter.new('/Users/kips/Public/prog/makersacademy/instagain/public/images/photos/aboriginal.jpg')}
  it 'should be able to set its height' do
    image.set_sizes
    expect(image.height).to eq 600
  end
  it 'should be able to create a working file' do
    image.working_file
    expect(image.working_name).to_not be nil
  end
  it 'should be able to alter a file' do
    image.nashville
    #image.gotham
    #image.toaster
    #image.lomo
    #image.kelvin

  end
end