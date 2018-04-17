require 'open-uri'
require 'watir'
require 'nokogiri'

url = 'https://www.bodybuilding.com/fun/dark_knight_workout.htm'

browser = Watir::Browser.new(:chrome)
browser.goto(url)

doc = Nokogiri::HTML.parse(browser.html)

p doc
