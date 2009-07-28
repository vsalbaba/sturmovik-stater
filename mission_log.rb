require 'inifile.rb'


class Plane
  attr_accessor :serial_number_with_pilot, :pilot_name, :kills, :damaged, :destroyed, :skill
  def initialize(serial_number, pilot_name = 'AI')
    @serial_number_with_pilot = serial_number
    @pilot_name = pilot_name
    @kills = []
    @damaged = []
    @destroyed = []
    @skill = 0
    @@plane_types ||= {
    # BLUE
    # rada Bf-109
      'air.BF_109E4'       => {:name => 'Bf-109 E-4', :side => "BLUE"},
      'air.BF_109E7'       => {:name => 'Bf-109 E-7', :side => "BLUE"},
      'air.BF_109F4'       => {:name => 'Bf-109 F-4', :side => "BLUE"},
      'air.BF_109G2'       => {:name => 'Bf-109 G-2', :side => "BLUE"},
    # rada Bf-110 ,
      'air.BF_110C4B'      => {:name => 'Bf-110 C-4/B', :side => "BLUE"},
    # rada Ju ,
      'air.JU_88A4'        => {:name => 'Ju-88 A-4', :side => "BLUE"},
    # rada ,
      'air.IAR_80'         => {:name => 'IAR-80', :side => "BLUE"},
      'air.IAR_81A'        => {:name => 'IAR-81A', :side => "BLUE"},

    # RED
    # rada I
      'air.I_153_M62'      => {:name =>'I-153', :side => "RED"},
      'air.I_153P'         => {:name =>'I-153', :side => "RED"},
      'air.I_16TYPE18'     => {:name =>'I-16', :side => "RED"},
      'air.I_16TYPE24'     => {:name =>'I-16', :side => "RED"},
    # rada Pe
      'air.PE_2SERIES1'    => {:name =>'Pe-2', :side => "RED"},
    # rada Yak
      "air.YAK_1"          => {:name =>'Yak-1', :side => "RED"},
    # rada SB
      'air.SB_2M103'       => {:name =>'SB 2M-103', :side => "RED"},
    # rada Lagg
      'air.LAGG_3SERIES4'  => {:name =>'Lagg-3', :side => "RED"},
    # rada Hurricane 
      'air.HurricaneMkIIb' => {:name =>'Hurricane Mk.IIb', :side => "RED"},
    # rada Mig 
      'air.MIG_3UD'        => {:name =>'Mig-3', :side => "RED"},
    # rada La 
      'air.LA_5'           => {:name =>'La-5', :side => "RED"},
    # rada Il 
      'air.IL_2_1941Early' => {:name =>'Il-2 Early', :side => "RED"}
    }
  end
  
  def side
    @side ||= @@plane_types[@raw_plane_type][:side] || "Unknown"
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
  
  def raw_plane_type=(object)
    @raw_plane_type = object
    @plane_type = humanize_object_name(object)
  end
  
  def plane_type
    @plane_type
  end
  
  def ==(obj)
    self.serial == obj.serial
  end
  
  def remove_damaged_killed_conflicts!
    @damaged.delete_if do |plane|
      @kills.include? plane
    end
  end
  
  def human?
    @pilot_name != 'AI'
  end

  def humanize_object_name(object)
    @human_name ||= @@plane_types[object][:name] || object
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
    damage_regexp = /^\d\d:\d\d:\d\d (.*) damaged by #{plane.serial} at .*$/
    destroyed_regexp = /^\d\d:\d\d:\d\d (.*) destroyed by #{plane.serial} at .*$/
      @log.each do |line|
        case  line
        when kill_regexp:
          killed_plane = Plane.new( $1+"(0)")
          killed_plane = @planes[@planes.index(killed_plane)] if @planes.values.include? killed_plane
          plane.kills << killed_plane
        when damage_regexp:
          damaged_plane = Plane.new( $1+"(0)")
          damaged_plane = @planes[@planes.index(damaged_plane)] if @planes.values.include? damaged_plane
          plane.damaged << damaged_plane
        when destroyed_regexp:
          plane.destroyed << $1
        end
      end
    end

    @planes.each_value do |plane|
      plane.remove_damaged_killed_conflicts!
    end
     
    # @planes.each_value do |plane|
    #   p plane.damaged unless plane.damaged.empty?
    # end

    #parse objects
    @objects_hash = IniFile.load(@objects[1..-2],{:parametr => '\s', :is_string => true})
    @planes.each_value do |plane|
      plane.raw_plane_type = @objects_hash[plane.unit]["Class"]
      plane.kills.each do |kill|
        kill.raw_plane_type = @objects_hash[kill.unit]["Class"]
        kill.skill = @objects_hash[kill.unit]["Skill"]
      end
      plane.damaged.each do |damaged|
        damaged.raw_plane_type = @objects_hash[damaged.unit]["Class"]
        damaged.skill = @objects_hash[damaged.unit]["Skill"]
      end
    end
  end
end
