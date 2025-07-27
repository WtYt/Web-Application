class ResultController < ApplicationController
  attr_accessor :latitude, :longitude, :place, :message, :status, :weather, :weather_code, :weather_code_h, :weather_temp_h

  # page renderer
  def weather
    # when accessed /result directly with GET method
    if @status == -1
      @message = "Invalid request. Please back to the top page, or watch world map."
    end
  end

  def initialize
    super # Call the parent class's initialize method
    @status = -1
  end

  def post
    require_relative "../lib/open_meteo_url_builder"
    require_relative "../lib/my_open_meteo_functions"
    require_relative "../lib/coordinates_searcher"
    require 'net/http'
    require 'json'

    # get coordinates of input place
    word = params[:place]
    coordinates = get_coordinates(word)
    @longitude = coordinates[0]
    @latitude = coordinates[1]
    @place = coordinates[2]

    # null check
    if coordinates[0].nil? || coordinates[1].nil? || coordinates[0].nan? || coordinates[1].nan? 
      @status = 0
      @message = "Failed to get coordinates, show you random place weather"
      @longitude = (rand(3600000) - 1800000).to_f / 10000.0
      @latitude = (rand(1600000) - 800000).to_f / 10000.0
      @place = "Random place"
    end

    # build open meteo api url
    murlbld = MeteoURLBuilder.new(@longitude, @latitude)
    murlbld.add_current_parameter("weather_code")
    murlbld.add_hourly_parameter("temperature_2m")
    murlbld.add_hourly_parameter("weather_code")
    murlbld.set_timezone("Asia%2FTokyo")
    url = murlbld.build_url
    @status = 1
    #puts url

    # get weather info from open meteo api
    response = Net::HTTP.get(URI(url))
    weather_info = JSON.parse(response)

    # infomation to variable
    @weather_code = weather_info.dig("current", "weather_code").to_i
    @weather = code2Weather(weather_code)
    @weather_code_h = weather_info.dig("hourly", "weather_code")
    @weather_h = @weather_code_h.map { |code| code2Weather(code.to_i) }
    @weather_temp_h = weather_info.dig("hourly", "temperature_2m")

    @message = "It's #{@weather} in #{@place}."

    # render page
    render :weather
  end
end
