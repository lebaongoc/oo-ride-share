require "csv"
require "time"
require "awesome_print"
require_relative "passenger"
require_relative "trip"

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(directory: "./support")
      @passengers = Passenger.load_all(directory: directory)
      @trips = Trip.load_all(directory: directory)
      @drivers = Driver.load_all(directory: directory)
      connect_trips
    end

    def find_passenger(id)
      Passenger.validate_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    def find_driver(id)
      Driver.validate_id(id)
      return @drivers.find { |driver| driver.id == id }
    end

    def inspect
      #Make puts output more useful
      return "#<#{self.class.name}:0x#{object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    def request_trip(passenger_id)
      assigned_driver = @drivers.find(ifnone = nil) do |driver|
        driver.status == :AVAILABLE
      end
      assigned_driver.status = :UNAVAILABLE
      return Trip.new ({id: 8,
                        passenger_id: passenger_id,
                        start_time: Time.new().to_s,
                        end_time: Time.new().to_s,
                        cost: 23.45,
                        rating: 3,
                        driver: assigned_driver})
    end

    private

    def connect_trips
      @trips.each do |trip|
        passenger = find_passenger(trip.passenger_id)
        driver = find_driver(trip.driver_id)
        trip.connect_passenger(passenger)
        trip.connect_driver(driver)
      end

      return trips
    end
  end
end
