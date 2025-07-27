require 'net/http'
require 'json'

# Get location name, return [latitude, longitude, fullname]
def get_coordinates(name)
  url = URI("https://msearch.gsi.go.jp/address-search/AddressSearch?q=#{URI.encode_www_form_component(name)}")
  response = Net::HTTP.get(url)
  locations = JSON.parse(response)
  return [Float::NAN, Float::NAN, "not found"] if locations.empty?

  title_list = locations.map { |location| location["properties"]["title"] }
  index = title_list.find_index { |title| /.*#{Regexp.escape(name)}$/ =~ title }
  return [Float::NAN, Float::NAN, "not found"] if index.nil?

  coordinates = [
    locations[index]["geometry"]["coordinates"][0],
    locations[index]["geometry"]["coordinates"][1],
    locations[index]["properties"]["title"]
  ]
  coordinates
end

# module test
def main
  puts get_coordinates("豊洲キャンパス").inspect
  puts get_coordinates("熊谷高等学校").inspect
  puts get_coordinates("ユニバーサル・スタジオ・ジャパン").inspect
  puts get_coordinates("ディズニーランド").inspect
end

if __FILE__ == $0
  main
end
