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

api_key = get_api_key

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
lat = coordinates["lat"]
lng = coordinates["lng"]

p [lat, lng]
