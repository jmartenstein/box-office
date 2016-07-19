# gather_data.rb
# Justin Martenstein, April 2016

require 'rubygems'
require 'optparse'
require 'ostruct'
require 'nokogiri'
require 'open-uri'
require 'pp'


def webpage_to_table(page, xpath, sub_xpath)

  rows = []
  page.xpath(xpath).each do |row|
    cells = row.xpath(sub_xpath).map{|a| "#{a.text}"}
    rows.push(cells) if !cells.empty?
  end

  return rows

end

def find_url_by_substring(url, substring)

  page = Nokogiri::HTML(open(url))
  
  xpath_str ="//a[contains(@href, '" + substring + "')]/@href"
  url = page.xpath(xpath_str)[0]

  return url

end

options = OpenStruct.new
options.data_type = :pricing
options.data_source = :pbo

OptionParser.new do |opts|
  opts.banner = "Usage: gather_data.rb [options]"
  opts.on("-d", "--data [TYPE]", [:pricing, :actuals, :forecast],
          "Set data type (pricing, forecast, actuals)") do |d|
    options[:data_type] = d
  end
  opts.on("-s", "--source [TYPE]", [:pbo, :fml, :bom],
          "Set data source (pbo, fml, bom)") do |f| 
    options[:data_format] = f
  end
  opts.on("-u", "--url [address]", "Set an optional URL for importing") do |u|
    options[:url] = u
  end
end.parse!

abort "Incorrect data type specificed" if options.data_type.nil?
abort "Incorrect data source specified" if options.data_source.nil?

# set parameters for each type of data
if options.data_type == :pricing
  url       = 'https://fantasymovieleague.com/researchvault'
  xpath     = "//table[@class='tableType-group hasGroups']//tr"
  sub_xpath = "./td/div//span/span"
elsif options.data_type == :forecast
  url       = find_url_by_substring("http://pro.boxoffice.com/?s=weekend+forecast", 
                                    "weekend-forecast") 
  xpath     = "//div[@class='post-container']//tr"
  sub_xpath = "./td"
elsif options.data_type == :actuals
  url       = find_url_by_substring("http://pro.boxoffice.com/?s=weekend+actuals", 
                                    "weekend-actuals") 
  xpath     = "//table[@class='sdt']//tr"
  sub_xpath = "./td"
end

# override the default URL if passed in from command line
url = options[:url] if options[:url]

page = Nokogiri::HTML(open(url))
table = webpage_to_table(page, xpath, sub_xpath )

if table.empty?
  puts "No rows retrieved! Maybe the webpage changed?"
  exit 1
end

# data post-processing
table.map{ |a| a[1].slice!(0,3) } if options.data_type == :pricing
table.map{ |a| a[2].gsub!(/\D/,'') } if options.data_type == :forecast
table.map{ |a| a[3].gsub!(/\D/,'') } if options.data_type == :forecast

table.each do |row|
  puts row.map{|a| "\"#{a}\""}.join(",") unless row.empty?
end

