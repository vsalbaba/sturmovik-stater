# encoding: utf-8
require 'rubygems'
require 'haml'
require 'sass'
require 'chronic'
require 'pilot_mission_log'
require 'pilot_mission_parsed'
require 'mission_log'
require 'name_generator/dumb_generator'
include NamesGenerator
module Enumerable
  def group_by
    assoc = Hash.new

    each do |element|
      key = yield(element)

      if assoc.has_key?(key)
        assoc[key] << element
      else
        assoc[key] = [element]
      end
    end

    assoc
  end
end

File.open(ARGV[0] || "NGen.log", 'r') do |file|
   stats = file.readlines
   @missions = []
   while stats.index("===== eventlog.lst =====\n") do
     mission = stats.slice!(0..stats.index("-------------\n"))
     mission[-1].rstrip!
     mission_object = MissionLog.new(mission)
     mission_object.mission = mission_object.mission.sort_by{|pilot| pilot.score}.reverse
     @missions << mission_object
  end
end

@overall = []
@missions.map(&:mission).flatten.group_by(&:name).each_value do |value|
  @overall << value.inject {|sum, n| sum + n}
end
@missions.reverse!
@overall = @overall.sort_by{|pilot| pilot.score}.reverse


File.open((ARGV[1] || "output") + ".html", "w") do |file|
  file.write Haml::Engine.new(File.read("template.html.haml")).render(self)
end

File.open("output.css", "w") do |file|
  file.write Sass::Engine.new(File.read("template.sass"), {:encoding => 'utf-8'}).render
end
