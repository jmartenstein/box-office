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

OptionParser.new do |opts|
  opts.banner = "Usage: gather_data.rb [options]"
  opts.on("-d", "--data [TYPE]", [:pricing, :actuals, :forecast],
          "Set data type (pricing, forecast, actuals") do |d|
    options.data_type = d
  end
end.parse!
abort "Incorrect type specificed" if options.data_type.nil? 

# set parameters for each type of data
if options.data_type == :pricing
  url       = 'http://fantasymovieleague.com/researchvault'
  xpath     = "//table[@class='tableType-group hasGroups']//div[@class='text']"
  sub_xpath = "./span"
elsif options.data_type == :forecast
  url       = find_url_by_substring("http://pro.boxoffice.com", 
                                    "weekend-forecast") 
  xpath     = "//div[@class='post-container']//tr"
  sub_xpath = "./td"
elsif options.data_type == :actuals
  url       = find_url_by_substring("http://pro.boxoffice.com", 
                                    "weekend-actuals") 
  xpath     = "//table[@class='sdt']//tr"
  sub_xpath = "./td"
end

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

