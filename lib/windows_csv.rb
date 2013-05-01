class WindowsCsv
  ENCODING = Encoding::UTF_16LE
  BOM = "\377\376".force_encoding(ENCODING) # Byte Order Mark
  COL_SEP = "\t"
  QUOTE_CHAR = "\""
  
  def self.foreach(path)
    require "rubygems"
    require "csv_lazy"
    
    File.open(path, "rb", :encoding => "UTF-8") do |fp|
      fp.sysread(2)
      
      Csv_lazy.new(:debug => false, :io => fp, :col_sep => COL_SEP, :quote_char => QUOTE_CHAR) do |row|
        yield row
      end
    end
    
    nil
  end
  
  def initialize(args)
    require "csv"
    
    @args = args
    
    if @args[:path]
      fp = File.open(@args[:path], "wb", :encoding => ENCODING)
      @args[:io] = fp
    end
    
    begin
      @args[:io].write(BOM)
      
      ::CSV.open(@args[:io], "wb", :col_sep => COL_SEP, :quote_char => QUOTE_CHAR, :force_quotes => true) do |csv|
        @csv = csv
        yield self
      end
    ensure
      fp.close if fp
    end
  end
  
  def <<(row)
    encoded = []
    
    row.each do |col|
      if col.is_a?(Time) or col.is_a?(DateTime)
        encoded << col.strftime("%Y-%m-%d %H:%M")
      elsif col.is_a?(Date)
        encoded << col.strftime("%Y-%m-%d")
      else
        encoded << col
      end
    end
    
    @csv << encoded
    
    return nil
  end
end