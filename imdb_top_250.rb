require 'nokogiri'
require 'rest-client'
require 'csv'
require 'pry'

def scrape_data
  movies = []
  puts "starting..."

  top_250_url = "https://www.imdb.com/chart/top"
  top_250_doc = Nokogiri::HTML(RestClient.get(top_250_url))
  puts "finished getting Nokogiri doc..."
  cnt = 0
  top_250_doc.search('.titleColumn a').each do |element|
    sleep(1)
    cnt +=1
    puts "working on movie #{cnt}/250"
    title = element.text
    href = element['href']

    movie_url = "https://www.imdb.com#{href.split('?')[0]}"

    movie_doc = Nokogiri::HTML(RestClient.get(movie_url))

    rating = movie_doc.search('.ratingValue strong span').text
    content_rating = movie_doc.search('.subtext').first.children[1]['content']
    duration = movie_doc.search('.subtext').first.children[5].text.strip
    release_year = movie_doc.search('#titleYear').children[1].text
    summary = movie_doc.search('.summary_text').text.strip
    director = movie_doc.search("span[itemprop='director'] span").text

    budget = ""
    gross_usa = ""
    gross_worldwide = ""

    movie_doc.search('.txt-block').each do |element|
      text = element.text.strip

      if text.include?("Budget:")
        budget = text.gsub(/\D/, '')
      elsif text.include?("Gross USA:")
        gross_usa = text.split[1].gsub(/\D/, '')
      elsif text.include?("Cumulative Worldwide Gross:")
        gross_worldwide = text.gsub(/\D/, '')
      end
    end

    movie = {
      title: title,
      href: movie_url,
      rating: rating,
      summary: summary,
      content_rating: content_rating,
      duration: duration,
      release_year: release_year,
      director: director,
    #   writers: [writers],
    #   stars: [stars],
       budget: budget,
    #   opening_weekend: opening_weekend,
       gross_usa: gross_usa,
       gross_worldwide: gross_worldwide
    }

    p movie
    save_to_csv(movie)

    movies << movie
  end
end

def save_to_csv(movie)
  csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
  filepath    = 'movies.csv'

  CSV.open(filepath, 'ab', csv_options) do |csv|
    # csv << ["Title", "Rating", "Summary", "Content Rating", "Duration", "Release Year", "Director", "Budget", "Gross USA", "Gross Worldwide"]
    csv << [movie[:title], movie[:rating], movie[:summary], movie[:content_rating], movie[:duration], movie[:release_year], movie[:director], movie[:budget], movie[:gross_usa], movie[:gross_worldwide]]
  end
end

scrape_data
