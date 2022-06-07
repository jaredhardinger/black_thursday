require 'csv'
require_relative 'customer'
require_relative 'methodable'

class CustomerRepository
  include Methodable
  attr_reader :all

  def initialize(filepath)
    @filepath = filepath
    @all = []
    CSV.foreach(@filepath, headers: true, header_converters: :symbol) do |row|
      @all << Customer.new(row)
    end
  end

  def find_all_by_first_name(first_name)
    @all.find_all do |customer|
      customer.first_name.downcase.include?(first_name.downcase)
    end
  end

  def find_all_by_last_name(last_name)
    @all.find_all do |customer|
      customer.last_name.downcase.include?(last_name.downcase)
    end
  end
end
