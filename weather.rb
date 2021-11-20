require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'csv'

class Weather
  attr_reader :day
  attr_reader :min_temperature
  attr_reader :max_temperature
  attr_reader :wind

  def initialize (day, min_temperature, max_temperature, wind)
    @day = day
    @min_temperature = "#{(min_temperature.to_i - 32) *  5/9}°"
    @max_temperature = "#{(max_temperature.to_i - 32) *  5/9}°"
    @wind = wind
  end
end

def Weather.scrap_weather()
  url = "https://weather.com/weather/tenday/l/6f54d7ce444ce6e8cbc601d44ea101f21e23f78caca2d78b4b772e9b68805f41"
  puts "Parsing weather on #{url}"
  html = open(url)

  doc = Nokogiri::HTML(html)


  CSV.open("./weather.csv", "w")
  CSV.open("./weather.csv", "a") do |csv|
    csv << ["Day","Minimum temperature","Maximum temperature","Wind status"]
  end


  doc.xpath("//details[contains(@id,'detailIndex')]").each do |weather_elem|
    CSV.open("./weather.csv", "a") do |csv|
      parsed_data = Weather.new(
        weather_elem.css("[data-testid^='daypartName']").text.strip,
        weather_elem.css("span[data-testid='lowTempValue'] > span[data-testid='TemperatureValue']").text.strip,
        weather_elem.css("div[data-testid='detailsTemperature'] > span[data-testid='TemperatureValue']").text.strip,
        weather_elem.css("div[data-testid='wind'] > span[data-testid='Wind']").text.strip
      )

      if parsed_data.day != "" #<-- if it isn't empty -->
        csv << [parsed_data.day,parsed_data.min_temperature,parsed_data.max_temperature,parsed_data.wind]
      end
    end
  end
end

Weather.scrap_weather
