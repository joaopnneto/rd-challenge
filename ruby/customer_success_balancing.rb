require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
    @available_cs = available_cs
  end

  # Returns the ID of the customer success with most customers
  def execute
    # Write your solution here
    busiest_cs(build_cs)
  end
end

private

def busiest_cs(params)
  return 0 if params.size.zero?
  return 0 if draw(params)
  return params.first[:id] if params.size.eql? 1

  params.first[:count].zero? ? params.max_by { |value| value[:count] }[:id] : params.first[:id]
end

def build_cs
  cs_count = Hash.new(0)
  customer_count = []
  @available_cs.each do |cs|
    cs[:count] = 0
    @customers.each do |customer|
      if customer[:score] <= cs[:score] && !customer_count.include?(customer[:id])
        cs_count[cs[:id]] += 1
        customer_count.push(customer[:id])
      end
      cs[:count] = cs_count[cs[:id]] || 0
    end
  end
end

def available_cs
  @customer_success.delete_if { |cs| @away_customer_success.include?(cs[:id]) && cs[:score] < 10_000 }
                   .sort_by! { |cs| cs[:score] }
end

def draw(cs_params)
  draw_count = Hash.new(0)
  cs_params.each { |cs| draw_count[cs[:count]] += 1 }
  values = draw_count.values
  (values.first == values.last) && (values.first > 1 && values.last > 1)
end

# def validate_params
#   binding.pry
#   abstention && max_cs && max_customer
# end

# def abstention
#   @away_customer_success.size <= (@customer_success.size / 2).floor
# end

# def max_cs
#   @customer_success.size < 1000
# end

# def max_customer
#   @customers.size < 1_000_000
# end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  def test_scenario_eight
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 95, 75]),
      build_scores([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
