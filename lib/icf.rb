require 'addressable/uri'
require 'launchy'
require 'rest-client'
require 'json'

def get_api_key
  api_key = nil
  begin
    api_key = File.read('./../.api_key').chomp
  rescue
    puts "Unable to read '.api_key'. Please provide a valid Google API key."
    exit
  end
end

def get_address
  puts "what's your address?"
  address_desc = gets.chomp

  address_uri = Addressable::URI.new(
                :scheme => "https",
                :host => "maps.googleapis.com",
                :path => "maps/api/geocode/json",
                :query_values => {:address => address_desc,
                                  :sensor => false}
              ).to_s

  address_json = JSON.parse(RestClient.get(address_uri))

  coordinates =  address_json["results"].first["geometry"]["location"]
  [coordinates["lat"], coordinates["lng"]]
end

def get_ice_cream(address_pos)
  lat, lng = address_pos
  location = "#{lat},#{lng}"
  key = get_api_key
  keyword = 'Ice Cream'
  rankby = 'distance'

  ice_cream_uri = Addressable::URI.new(
                :scheme => "https",
                :host => "maps.googleapis.com",
                :path => "maps/api/place/nearbysearch/json",
                :query_values => {:location => location,
                                  :key => key,
                                  :keyword => keyword,
                                  :rankby => rankby,
                                  :sensor => false}
              ).to_s


  ice_cream_json = JSON.parse(RestClient.get(ice_cream_uri))

  first_result = ice_cream_json["results"].first

  name = first_result["name"]
  lat = first_result["geometry"]["location"]["lat"]
  lng = first_result["geometry"]["location"]["lng"]

  [name, lat, lng]
end

def get_directions(start_pos, end_pos)

  origin = "#{start_pos.first},#{start_pos.last}"
  destination = "#{end_pos.first},#{end_pos.last}"


  directions_uri = Addressable::URI.new(
                :scheme => "https",
                :host => "maps.googleapis.com",
                :path => "maps/api/directions/json",
                :query_values => {:origin => origin,
                                  :destination => destination,
                                  :sensor => false}
              ).to_s

  directions_json = JSON.parse(RestClient.get(directions_uri))
  steps_arr = directions_json["routes"].first["legs"].first["steps"]
  html_directions = steps_arr.map do |step|
    step["html_instructions"]
  end
end

def run
  start_pos = get_address

  first_result =  get_ice_cream(start_pos)
  end_pos = first_result[1..2]

  puts get_directions(start_pos, end_pos)
end

run