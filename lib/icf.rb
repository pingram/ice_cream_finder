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

def get_ice_cream(lat, lng)
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

# p get_api_key

def run
  lat, lng = get_address

  first_result =  get_ice_cream(lat, lng)
  p first_result



  # p [lat, lng]
end

run
