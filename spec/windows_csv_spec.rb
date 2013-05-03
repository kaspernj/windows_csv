#encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "WindowsCsv" do
  it "works" do
    require "tmpdir"
    require "digest"
    require "digest/md5"
    
    tmpfile = "#{Dir.tmpdir}/windows_csv_test_#{Digest::MD5.hexdigest(Time.now.to_f.to_s)}.csv"
    
    WindowsCsv.new(:path => tmpfile) do |csv|
      csv << ["Name1", "Name2", "Encoding", "Date", "Time", "DateTime", "MultiLine"]
      csv << ["Kasper", "Christina", "æøå", Date.new, Time.new, DateTime.new, "Multi\nLine"]
      csv << ["Thomas", "Nikolaj", "læp", nil, nil, nil, nil]
    end
    
    puts "Path: #{tmpfile}"
    
    count = 0
    WindowsCsv.foreach(tmpfile, :csv_args => {:headers => true}) do |row|
      count += 1
      #puts "Row: #{row}"
      
      if count == 1
        row[:Name2].should eql("Christina")
        row[:Encoding].should eql("æøå")
        row[:MultiLine].should eql("Multi\nLine")
      end
    end
    
    count.should eql(2)
  end
end
