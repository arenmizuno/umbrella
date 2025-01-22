# Write your soltuion here!
# /env_test.rb
require "http"
require "json"
require "dotenv/load"

# Keys
pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
gmaps_key = ENV.fetch("GMAPS_KEY")

# Finding location
pp "Where are you?"
user_location = gets.chomp
pp "Checking the weather at #{user_location}."

gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_key}"
raw_gmaps_data = HTTP.get(gmaps_url)
parsed_gmaps_data = JSON.parse(raw_gmaps_data)
results_array = parsed_gmaps_data.fetch("results")
first_result_hash = results_array.at(0)
geometry_hash = first_result_hash.fetch("geometry")
location_hash = geometry_hash.fetch("location")
latitude = location_hash.fetch("lat")
longitude = location_hash.fetch("lng")
pp "Your coordinates are #{latitude}, #{longitude}."

# Find weather 
pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{latitude},#{longitude}"
raw_pirate_weather_data = HTTP.get(pirate_weather_url)
parsed_pirate_weather_data = JSON.parse(raw_pirate_weather_data)
currently_hash = parsed_pirate_weather_data.fetch("currently")
current_temp = currently_hash.fetch("temperature")
pp "It is currently #{current_temp}°F."


# If statement because some might not have min data
minutely_hash = parsed_pirate_weather_data.fetch("minutely", false)
if minutely_hash
  next_hour_summary = minutely_hash.fetch("summary")
  pp "Next hour: #{next_hour_summary}"
end

# Hourly data
hourly_hash = parsed_pirate_weather_data.fetch("hourly")
hourly_data_array = hourly_hash.fetch("data")
next_twelve_hours = hourly_data_array[1..12]

# See if bring umbrella
precip_prob_threshold = 0.3 # can change based on preference
any_precipitation = false # temporary

next_twelve_hours.each do |hour_hash|
  precip_prob = hour_hash.fetch("precipProbability")
  if precip_prob > precip_prob_threshold
    any_precipitation = true
    precip_time = Time.at(hour_hash.fetch("time"))
    seconds_from_now = precip_time - Time.now
    hours_from_now = seconds_from_now / 60 / 60

    pp "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation."
  end
end

pp "No significant precipitation expected in the next 12 hours." unless any_precipitation
