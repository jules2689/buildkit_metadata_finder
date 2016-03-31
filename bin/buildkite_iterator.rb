#!/usr/bin/env ruby

class BuildkiteIterator
  include Enumerable

  def initialize(buildkite, relation = nil)
    if relation
      @response = relation.get(per_page: 100)
    else
      yield
      @response = buildkite.last_response
    end
  end

  def each(&block)
    response = @response

    loop do
      response.data.each(&block)
      return unless response.rels[:next]
      response = response.rels[:next].get
    end
  end
end
