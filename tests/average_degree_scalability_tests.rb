
require 'test/unit'
require 'average_degree'

class TestScalability < Test::Unit::TestCase
  attr :rolling_graph_1
  attr :rolling_graph_2
  attr :rolling_graph_combine
  attr :rolling_graph_single

  def setup
    @rolling_graph_1 = RollingHashtagGraph.new
    @rolling_graph_2 = RollingHashtagGraph.new
    @rolling_graph_combine = RollingHashtagGraph.new
    @rolling_graph_single = RollingHashtagGraph.new
  end

  def teardown
    @rolling_graph_1 = nil
    @rolling_graph_2 = nil
    @rolling_graph_combine = nil
    @rolling_graph_single = nil
  end

  def test_avg_degree_scaling
    @rolling_graph_single.add("Thu Oct 29 17:51:40 +0000 2015", "#a #b #c")
    @rolling_graph_single.add("Thu Oct 29 17:51:50 +0000 2015", "#a #b")
    @rolling_graph_single.add("Thu Oct 29 17:52:20 +0000 2015", "#d #c #e")
    @rolling_graph_single.add("Thu Oct 29 17:51:30 +0000 2015", "#a #d #e")
    @rolling_graph_single.add("Thu Oct 29 17:52:40 +0000 2015", "#e #f")
    assert(@rolling_graph_single.get_average_degree == 1.67, "Wrong avg degree")

    @rolling_graph_1.add("Thu Oct 29 17:51:40 +0000 2015", "#a #b #c")
    @rolling_graph_1.add("Thu Oct 29 17:51:50 +0000 2015", "#a #b")
    assert(@rolling_graph_1.get_average_degree == 2, "Wrong avg degree")

    @rolling_graph_2.add("Thu Oct 29 17:52:20 +0000 2015", "#d #c #e")
    @rolling_graph_2.add("Thu Oct 29 17:51:30 +0000 2015", "#a #d #e")
    @rolling_graph_2.add("Thu Oct 29 17:52:40 +0000 2015", "#e #f")
    assert(@rolling_graph_2.get_average_degree == 2, "Wrong avg degree")

    @rolling_graph_combine.combine(@rolling_graph_1)
    assert(@rolling_graph_combine.get_average_degree == 2, "Wrong avg degree")

    @rolling_graph_combine.combine(@rolling_graph_2)
    assert(@rolling_graph_combine.get_average_degree == 1.67, "Wrong avg degree")
  end
end
