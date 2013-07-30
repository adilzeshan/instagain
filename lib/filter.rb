require 'fastimage'


class Filter



  attr :image, :output, :working_name, :prefix, :width, :height, :tmp

  def initialize(image)
    @image = image
    @working_name = nil
    @width = nil
    @height = nil
    set_sizes
  end

  def self.apply_filter(photo,filter)
    if filter == "nashville"
      filter = Filter.new(photo)
      puts filter.inspect
      filter.nashville
    end
  end

  def set_sizes
    size = FastImage.size(@image)
    @width = size[0]
    @height  = size[1]
  end

  def working_file
    type = :jpg #FastImage.type(@image)
    @working_name= @image.slice(0...-4)+"_tmp."+type.to_s
    FileUtils.copy(@image, @working_name)
  end

  def finished_file(filter)
    type = :jpg #FastImage.type(@image)
    # rename working temporary file to output filename
    FileUtils.move(@working_name, @image.slice(0...-4)+"_"+filter+"."+type.to_s)
  end


  # ----------------------------------FILTER ACTIONS-----------------------------------------
  def border(input, color = 'black', width = 20)
    `convert #{input} -bordercolor #{color} -border #{width}x#{width} #{input}`
  end

  def frame(input, frame)
        `convert #{input} #{frame} -resize #{@width}x#{@height}! -unsharp 1.5×1.0+1.5+0.02  -flatten #{input}`
  end

  def colortone(input, color, level, type = 0)
    values = Hash.new
    values[:level] = level
    values[:inv_level] = 100 - level

    if type == 0
      negate = '-negate'
    else
      negate = ''
    end
    system "convert #{input} \\( -clone 0 -fill '#{color}' -colorize 100% \\) \\( -clone 0 -colorspace gray #{negate} \\) -compose blend -define compose:args=#{values[:level]},#{values[:inv_level]} -composite #{input}"
  end

  def vignette(input, color_1 = 'none', color_2 = 'black', crop_factor = 1.5)
    crop_x = (@width * crop_factor).floor
    crop_y = (@height * crop_factor).floor
     `convert  #{input} -size #{crop_x}x#{crop_y} radial-gradient:#{color_1}-#{color_2} -gravity center -crop #{@width}x#{@height}+0+0 +repage -compose multiply -flatten #{input}`
  end


  #------------------------------------FILTERS--------------------------------------------
  def nashville
    @frame = '/Users/kips/Public/prog/makersacademy/instagain/public/images/frames/Nashville'
    working_file
    colortone(@working_name, '#222b6d', 50, 0)
    colortone(@working_name, '#f7daae', 800, 1)
    `convert #{@working_name} -contrast -modulate 100,150,100 -auto-gamma #{@working_name}`
    frame(@working_name,@frame)
    finished_file("nashville")
  end

  def gotham
    working_file
    `convert #{@working_name} -modulate 120,10,100 -fill '#222b6d' -colorize 20 -gamma 0.5 -contrast -contrast #{@working_name}`
    border(@working_name)
    finished_file("gotham")
  end

   def toaster
    working_file
    colortone(@working_name, '#330000', 100, 0);

    `convert #{@working_name} -modulate 150,80,100 -gamma 1.2 -contrast -contrast #{@working_name}`

    vignette(@working_name, 'none', 'LavenderBlush3');
    vignette(@working_name, '#ff9966', 'none');
    frame(@working_name,@frame);

    finished_file("toaster")
  end

  def lomo
    @frame = '/Users/kips/Public/prog/makersacademy/instagain/public/images/frames/Kelvin'
   working_file

   `convert #{@working_name} -channel R -level 33% -channel G -level 33% #{@working_name}`

    vignette(@working_name)
    frame(@working_name,@frame);

    finished_file("lomo")
  end

  def kelvin
    working_file

    `convert #{@working_name} -auto-gamma -modulate 120,50,100 -size #{@width}x#{@height} -fill 'rgba(255,153,0,0.5)' -draw 'rectangle 0,0 #{@width},#{@height}' -compose multiply #{@working_name}`
    border(@working_name, 'grey', width = 30)
    frame(@working_name,@frame);
    finished_file("kelvin")
  end



end






