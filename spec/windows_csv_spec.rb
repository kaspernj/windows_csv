#encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "WindowsCsv" do
  it "works" do
    require "tmpdir"
    require "digest"
    require "digest/md5"
    
    tmpfile = "#{Dir.tmpdir}/windows_csv_test_#{Digest::MD5.hexdigest(Time.now.to_f.to_s)}.csv"
    
    WindowsCsv.new(:path => tmpfile) do |csv|
      csv << ["Kasper", "Christina", "æøå", Date.new, Time.new, DateTime.new]
    end
    
    puts "Path: #{tmpfile}"
    
    begin
      WindowsCsv.foreach(tmpfile) do |row|
        #puts "Row: #{row}"
        row[1].should eql("Christina")
      end
    rescue => e
      puts e.inspect
      puts e.backtrace
      raise e
    end
  end
end
