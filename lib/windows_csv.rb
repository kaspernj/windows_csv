#This class was heavily inspired by the great Dipth! https://github.com/dipth
class WindowsCsv
  BOM = "\377\376".force_encoding(Encoding::UTF_16LE) # Byte Order Mark
  COL_SEP = ";"
  QUOTE_CHAR = "\""
  ROW_SEP = "\r\n"

  ARGS = {
    :col_sep => COL_SEP,
    :quote_char => QUOTE_CHAR,
    :row_sep => ROW_SEP
  }

  REPLACES = {
    "\r\n" => "\\r\\n",
    "\r" => "\\r",
    "\n" => "\\n"
  }

  #Loops through a Windows CSV file with leading BOM, tabs as col-sep, quote char " and row sep \r\n
  def self.foreach(path, args = {})
    require "csv"

    File.open(path, "rb:bom|utf-16le") do |fp|
      csv_args = ARGS.clone
      csv_args.merge!(args[:csv_args]) if args[:csv_args]

      CSV.foreach(fp, **csv_args) do |row|
        if csv_args[:headers]
          real = {}
        else
          real = []
        end

        row.each do |col|
          if csv_args[:headers]
            real[col[0].to_sym] = WindowsCsv.unescape(col[1])
          else
            real << WindowsCsv.unescape(col)
          end
        end

        yield real
      end
    end

    nil
  end

  def initialize(args)
    require "csv"

    @args = args

    if @args[:path]
      fp = File.open(@args[:path], "w", :encoding => Encoding::UTF_8)
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

    @args[:io].write CSV.generate_line(encoded, **ARGS).encode(Encoding::UTF_16LE)

    return nil
  end

  def self.escape(str)
    str = str.to_s

    REPLACES.each do |key, val|
      str = str.gsub(key, val)
    end

    return str
  end

  def self.unescape(str)
    str = str.to_s

    REPLACES.each do |key, val|
      str = str.gsub(val, key)
    end

    return str
  end
end