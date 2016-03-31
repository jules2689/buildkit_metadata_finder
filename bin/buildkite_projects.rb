#!/usr/bin/env ruby

require 'octokit'
require 'base64'
require 'yaml'

class BuildkiteProjects
  include Enumerable

  def initialize(projects)
    @projects = projects
  end

  def each
    @projects.each { |p| yield(p) }
  end

  def with_query_rule(rules)
    matching do |project|
      (project.steps || []).any? do |step|
        found_rules = step.agent_query_rules || []

        if step[:command] && step[:command].start_with?('buildkite-agent pipeline upload')
          found_rules += extract_rules_from_pipeline(step[:command], project[:repository]) 
        end

        rules.all? { |r| found_rules.include?("#{r}=true") || 
                         found_rules.include?("#{r}=1") || 
                         found_rules.include?(r) }
      end
    end
  end

  def matching(&block)
    self.class.new(select(&block))
  end

  private

  def extract_rules_from_pipeline(command, repository) 
    repo = extract_repo(repository)
    pipeline_file = if command.split(' ').length > 3
      command.split(' ').last
    else
      '.buildkite/pipeline.yml'
    end

    begin
      base64 =  Base64.decode64 github.contents(repo, path: pipeline_file)[:content]
      agents = YAML.load(base64)['steps'].collect { |a| a['agents'] }
      agents.reject(&:nil?).collect { |a| a.map { |k,v| "#{k}=#{v}" } }.flatten.uniq
    rescue Octokit::NotFound
      puts "Couldn't find #{pipeline_file} in #{repository}"
      []
    end
  end

  def extract_repo(repo_path)
    repo = repo_path.dup
    repo.slice!('git@github.com:')
    repo.slice!('.git')
    repo
  end

  def github
    @client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  end
end
