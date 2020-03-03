# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# set admin user
User.create!(email: 'admin@greenthumb.rocks', password: '123456', admin: true)

# initialize weather station
chc_stn = { id: 7_910_036, lon: 172.745865, lat: -43.645779,
            name: 'Christchurch City', country: 'NZ' }
WeatherStation.create!(chc_stn)
