class Merchant
  attr_reader :id, :name, :created_at, :updated_at

  def initialize(attributes)
    @id = attributes[:id].to_i
    @name = attributes[:name]
    @created_at = attributes[:created_at]
    @updated_at = attributes[:updated_at]
  end

  def update(attributes)
    @name = attributes[:name] unless attributes[:name].nil?
    @updated_at = Time.now
  end
end
