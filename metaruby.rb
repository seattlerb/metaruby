require 'everything'

class ZArray

  def self.[](*args);
    a = ZArray.new(args.length)

    args.each_with_index do |val, i|
      a[i] = val
    end

    return a
  end

  def  initialize(size=0, default=nil); 
    @length = size
    @default = default
    @_c_data = Array.new(@length, @default)
  end

  def length; 
    return @length
  end

  def [](*args); 
    return @_c_data.[](*args)
  end

  def []=(*args); 
    return @_c_data.[]=(*args)
  end

end
