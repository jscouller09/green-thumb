# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# set admin user
User.destroy_all
User.create!(email: 'admin@greenthumb.rocks', password: '123456', admin: true)
puts "Created admin user!"

# initialize weather station (if not already in DB)
chc_stn = { id: 7_910_036, lon: 172.745865, lat: -43.645779,
            name: 'Christchurch City', country: 'NZ' }
if WeatherStation.find(chc_stn[:id]).nil?
  WeatherStation.create!(chc_stn)
  puts "Added Christchurch 7910036 station to DB!"
else
  puts "Skipping Christchurch 7910036 station as already in DB..."
end
