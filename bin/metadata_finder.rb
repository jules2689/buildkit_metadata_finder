#!/usr/bin/env ruby

require_relative 'buildkite_iterator'
require_relative 'buildkite_projects'
require 'buildkit'

class MetadataFinder
  def self.find(metadata)
    m = MetadataFinder.new
    m.buildkite_projects.with_query_rule([metadata].flatten)
  end
  
  def buildkite_projects
    projects = BuildkiteIterator.new(buildkite) { buildkite.projects(ENV['BUILDKITE_ORG']) }
    BuildkiteProjects.new(projects.to_a)
  end

  def buildkite
    @buildkite ||= Buildkit.new(token: ENV['BUILDKITE_API_TOKEN'])
  end
end