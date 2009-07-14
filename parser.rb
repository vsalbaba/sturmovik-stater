require 'rubygems'
require 'haml'
require 'sass'
require 'chronic'
require 'pilot_mission_log'
require 'pilot_mission_parsed'
require 'mission_log'

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
     mission_log = mission_object.mission
     lasted_minutes = mission_log.pop
     @missions << [mission_log.sort_by{|pilot| pilot.score}.reverse, lasted_minutes]
  end
end

@overall = []
@missions.map(&:first).flatten.group_by(&:name).each_value do |value|
  @overall << value.inject {|sum, n| sum + n}
end
@missions.reverse!
@overall = @overall.sort_by{|pilot| pilot.score}.reverse


File.open((ARGV[1] || "output") + ".html", "w") do |file|
  file.write Haml::Engine.new(File.read("template.html.haml")).render(self)
end

File.open("output.css", "w") do |file|
  file.write Sass::Engine.new(File.read("template.sass")).render
end
