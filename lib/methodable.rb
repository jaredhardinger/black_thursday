module Methodable

  def find_by_id(id)
    @all.find { |thing| thing.id == id }
  end

  def create(attributes)
    attributes[:id] = @all.max_by {|thing| thing.id }.id + 1
    @all << @all.last.class.new(attributes)
    @all.last
  end

  def update(id, attributes)
    if find_by_id(id)
      find_by_id(id).update(attributes)
    end
  end

  def delete(id)
    @all.delete_if { |thing| thing.id == id }
  end

  def inspect
    "#<#{self.class} #{@all.size} rows>"
  end
end
