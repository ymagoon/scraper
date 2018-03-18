require 'open-uri'
require 'watir'
require 'nokogiri'

url = 'https://sfbay.craigslist.org/d/computer-gigs/search/cpg'
#url = 'http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/HTML/Document'
#document = open(url, {ssl_verify_mode: 0})
browser = Watir::Browser.new(:chrome)
browser.goto(url)

doc = Nokogiri::HTML.parse(browser.html)

data = [] #store data
total_count = doc.css('.totalcount').first.text.to_i #total count is listed twice on the page

doc.css('.rows').css('.result-row').each_with_index do |row,index|
  title = row.css('.hdrlnk').text
  date = row.css('.result-date').attribute('datetime').value
  location = row.css('.result-hood').text

  data << [index + 1, title, date, location]
end

if total_count > 120
  loops = total_count / 120 #total number of webpages

  loops.times.with_index do |index|
    page = (index + 1) * 120

    new_url = 'https://sfbay.craigslist.org/search/cpg?s=' + page.to_s
    browser.goto(new_url)
    doc = Nokogiri::HTML.parse(browser.html)

    doc.css('.rows').css('.result-row').each do |row|
      title = row.css('.hdrlnk').text
      date = row.css('.result-date').attribute('datetime').value
      location = row.css('.result-hood').text

      data << [data.last[0] + 1, title, date, location]
    end
  end
end
puts data.inspect
