# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
play = Event.create(name: "A Midsummer Night's Dream")

performances = []
first_performance = play.performances.create(start_time: "2018-02-08 19:00:00")
performances << first_performance

next_performance = play.performances.create(start_time: "2018-02-09 19:00:00")
next_performance.save!
performances << next_performance

performances.each do |performance|
  10.times do
    Ticket.create(performance: performance,
                      status: "unsold",
                      price_cents: 1500)
    end
end

