require 'inifile.rb'


class Plane
  attr_accessor :serial_number_with_pilot, :pilot_name, :kills
  def initialize(serial_number, pilot_name)
    @serial_number_with_pilot = serial_number
    @pilot_name = pilot_name
    @kills = []
  end
  
  def serial
    @serial ||= @serial_number_with_pilot[0..-4]
  end
  
  def number
    @plane_num ||= @serial[-1].chr
  end
  
  def unit
    @unit ||= serial[0..-2]
  end
  
  def plane_type=(object)
    @plane_type = humanize_object_name(object)
  end
  
  def plane_type
    @plane_type
  end

private
  def humanize_object_name(object)
    plane_types ||= {
      "air.YAK_1" => 'Yak-1',
      'air.BF_109F4' => 'Bf-109 F4',
      'air.PE_2SERIES1' => 'Pe-2',
      'air.I_16TYPE18' => 'I-16',
      'air.I_16TYPE24' => 'I-16',
      'air.BF_110C4B'  => 'Bf-110 C-4/B',
      'air.SB_2M103'   => 'SB 2M-103'
    }
    plane_types[object] || object
  end
end

class MissionLog
  attr_accessor :mission, :real_world_date, :lasted_minutes, :planes
  
  def initialize(eventlog)
    parse_eventlog(eventlog)

    @mission = []
    while (pilot_stats = @stats.slice!(0,27)).size == 27 do
      @mission << PilotMissionLog.parse(pilot_stats)
    end
  
    parse_parsed
    
    @parsed_pilots.each do |parsed_pilot|
      pilot = @mission.find { |log_pilot| log_pilot.name == parsed_pilot.name}
      if pilot then
        pilot.plane = parsed_pilot.plane
        if pilot.last_state == "Left the Game" then
          pilot.last_state = parsed_pilot.last_state unless parsed_pilot.last_state == "Disconnected"
        end
      else
        @mission << parsed_pilot.log_pilot
      end
    end
    
    parse_log
    return self
  end

private
  def parse_log
    reference_point = Chronic.parse("midnight")
    started_at = Chronic.parse(@log[2][0..7], :now => reference_point)
    ended_at = Chronic.parse(@log[-2][0..7], :now => reference_point)
    @real_world_date = @log[0][(@log[0].index("[").next)..(@log[0].index("]").pred-3)]
    @lasted_minutes = (ended_at-started_at).to_i/60
    parse_planes
  end
  
  def parse_parsed
    red_pilots = @parsed.slice((@parsed.index("RED PILOTS\n")+1)..(@parsed.index("BLUE PILOTS\n")-1))
    blue_pilots = @parsed.slice((@parsed.index("BLUE PILOTS\n")+1)..(@parsed.index("SUMMARY\n")-1))
    @parsed_pilots = (red_pilots + blue_pilots).map{|pilot| PilotMissionParsed.new(pilot)}
  end
  
  def parse_eventlog(eventlog)
    @briefing = eventlog.slice!(0..eventlog.index("===== eventlog.lst =====\n"))
    @log = eventlog.slice!(0..eventlog.index("-------------------------------------------------------\n"))
    @stats = eventlog.slice!(0..(eventlog.index("============ eof ==============\n")))
    @objects = eventlog.slice!(0..(eventlog.index("============ eof ==============\n")))
    @parsed = eventlog.slice!(0..(eventlog.index("============ eof ==============\n")))
  end
  
  def parse_planes
    @planes = {}
    #inventarize human planes
    regexp = /^\d\d:\d\d:\d\d (.*) seat occupied by (.*) at .*$/
    @log.each do |line|
      if line =~ regexp
        @planes[$2] = Plane.new($1, $2)
      end
    end
    #count kills for each plane
    @planes.each_value do |plane|
    kill_regexp = /^\d\d:\d\d:\d\d (.*) shot down by #{plane.serial} at .*$/
      @log.each do |line|
        if line =~ kill_regexp
          plane.kills << Plane.new( $1+"(0)",'AI')
        end
      end
    end
    #parse objects
    @objects_hash = IniFile.load(@objects[1..-2],{:parametr => '\s', :is_string => true})
    @planes.each_value do |plane|
      plane.kills.each do |kill|
        kill.plane_type = @objects_hash[kill.unit]["Class"]
      end
    end
  end
end
