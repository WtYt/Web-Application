require 'net/http'
require 'json'
require_relative 'coordinates_searcher'
require_relative 'my_open_meteo_functions'

# Open Meteo URL builder. for more infomation, see https://open-meteo.com/en/docs

class MeteoURLBuilder
  attr_accessor :latitude, :longitude, :hourly_parameters, :daily_parameters, :current_parameters, :timezone, :forecast_days, :url

  def initialize
    @url = "https://api.open-meteo.com/v1/forecast"
    @latitude = Float::NAN   # as a null number
    @longitude = Float::NAN  # as a null number
    @hourly_parameters = []  # should create Parameter class?
    @daily_parameters = []
    @current_parameters = []
    @timezone = nil
    @forecast_days = 1
  end

  def initialize(x, y)
    @url = "https://api.open-meteo.com/v1/forecast"
    @latitude = y
    @longitude = x
    @hourly_parameters = []
    @daily_parameters = []
    @current_parameters = []
    @timezone = nil
    @forecast_days = 1
  end

  def set_longitude(x)
    @longitude = x
  end

  def set_latitude(y)
    @latitude = y
  end

  def set_timezone(timezone)
    @timezone = timezone
  end

  def add_hourly_parameter(parameter)
    @hourly_parameters << parameter
  end

  def add_daily_parameter(parameter)
    @daily_parameters << parameter
  end

  def add_current_parameter(parameter)
    @current_parameters << parameter
  end

  def build_url
    return nil if @latitude.nil? || @longitude.nil? || @latitude.nan? || @longitude.nan?
    url = "#{@url}?longitude=#{format('%.4f', @longitude)}&latitude=#{format('%.4f', @latitude)}"
    url += "&hourly=#{@hourly_parameters.join(',')}" unless @hourly_parameters.empty?
    url += "&daily=#{@daily_parameters.join(',')}" unless @daily_parameters.empty?
    url += "&current=#{@current_parameters.join(',')}" unless @current_parameters.empty?
    url += "&timezone=#{@timezone}" if @timezone
    url += "&forecast_days=#{@forecast_days}"
    url
  end
end

# module test
def main
  word = "東京"
  coordinates = get_coordinates(word)
  puts "#{word}->#{coordinates[2]}"
  murlbld = MeteoURLBuilder.new(coordinates[0], coordinates[1])
  murlbld.add_current_parameter("weather_code")
  murlbld.add_hourly_parameter("temperature_2m")
  murlbld.add_hourly_parameter("weather_code")

  murlbld.set_timezone("Asia%2FTokyo")
  url = murlbld.build_url
  puts url
  response = Net::HTTP.get(URI(url))
  weather_today = JSON.parse(response)
  puts weather_today
  weather_code = weather_today.dig("current", "weather_code").to_i
  puts "#{coordinates[2]}の天気は#{code2WeatherJP(weather_code)}です。"
end

if __FILE__ == $0
  main
end