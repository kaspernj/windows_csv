#This class was heavily inspired by the great Dipth! https://github.com/dipth
class WindowsCsv
  ENCODING = Encoding::UTF_8
  
  BOM = "\377\376".force_encoding(Encoding::UTF_16LE) # Byte Order Mark
  COL_SEP = "\t"
  QUOTE_CHAR = "\""
  
  def self.foreach(path, args = {})
    require "rubygems"
    require "csv_lazy"
    
    File.open(path, "rb:bom|utf-16le") do |fp|
      csv_args = {:debug => false, :io => fp, :col_sep => COL_SEP, :quote_char => QUOTE_CHAR}
      csv_args.merge!(args[:csv_args]) if args[:csv_args]
      
      Csv_lazy.new(csv_args) do |row|
        real = []
        row.each do |col|
          real << col
        end
        
        yield row
      end
    end
    
    nil
  end
  
  def initialize(args)
    require "csv"
    
    @args = args
    
    if @args[:path]
      fp = File.open(@args[:path], "w", :encoding => ENCODING)
      @args[:io] = fp
    end
    
    begin
      @args[:io].write(BOM)
      yield self
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
        encoded << WindowsCsv.escape(col)
      end
    end
    
    @args[:io].puts CSV.generate_line(encoded, :col_sep => COL_SEP, :quote_char => QUOTE_CHAR).encode(Encoding::UTF_16LE)
    
    return nil
  end
  
  def self.escape(str)
    return str.to_s.gsub("\n", "\\r\\n")
  end
end