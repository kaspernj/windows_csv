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

    count = 0
    WindowsCsv.foreach(tmpfile, :csv_args => {:headers => true}) do |row|
      count += 1
      #puts "Row: #{row}"

      if count == 1
        expect(row).to include(
          Name2: "Christina",
          Encoding: "æøå",
          MultiLine: "Multi\nLine"
        )
      end
    end

    expect(count).to eq 2
  end
end
