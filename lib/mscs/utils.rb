  def utf8_to_utf16le(my_str)
    my_str = my_str + "\000\000" #double null termination - wtf
    my_str = begin
      if my_str.respond_to?(:encode)
        my_str.encode('UTF-16LE')
      else
        require 'iconv'
        Iconv.conv("UTF-16LE", "UTF-8", my_str)
      end
    end
    my_str
  end

  def utf16le_to_usascii(my_str)
    my_str = begin
      if my_str.respond_to?(:encode)
        my_str.encode('UTF-8')
      else
        require 'iconv'
        Iconv.conv("US-ASCII", "UTF-16LE", my_str)
      end
    end
    my_str.strip!
    my_str
  end
