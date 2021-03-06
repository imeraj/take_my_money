class ShoppingCart
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def tickets
    @tickets ||= user.tickets_in_cart
  end

  def events
    tickets.map(&:event).uniq.sort_by(&:name)
  end

  def performances_for(event)
    ids = tickets.pluck(:performance_id)
    Performance.where(id: ids).where(event_id: event.id).uniq.sort_by(&:start_time)
  end

  def performance_count
    tickets_by_performance.each_pair.each_with_object({}) do |pair, result|
      result[pair.first] = pair.last.size
    end
  end

  def tickets_by_performance
    tickets.group_by { |t| t.performance.id }
  end

  def subtotal_for(performance)
    tickets_by_performance[performance.id].sum(&:price)
  end

  def total_cost
    return Money.new(0) if tickets.size.zero?

    tickets.map(&:price).sum
  end
end