require 'rubygems'
require 'haml'
require 'chronic'
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

class PilotMissionLog
  attr_accessor :name, 
                :score, 
                :last_state, 
                :enemy_aircraft_kill,
                :enemy_static_aircraft_kill,
                :enemy_tank_kill,
                :enemy_car_kill, 
                :enemy_artillery_kill, 
                :enemy_AAA_kill, 
                :enemy_wagon_kill, 
                :enemy_ship_kill, 
                :friend_aircraft_kill, 
                :friend_static_aircraft_kill, 
                :friend_tank_kill, 
                :friend_car_kill, 
                :friend_artillery_kill, 
                :friend_AAA_kill, 
                :friend_wagon_kill, 
                :friend_ship_kill, 
                :fire_bullets, 
                :hit_bullets, 
                :hit_air_bullets, 
                :fire_roskets, 
                :hit_roskets, 
                :fire_bombs, 
                :hit_bombs,
                :land_count,
                :kia_count,
                :mia_count,
                :left_count,
                :hit_the_silk_count,
                :in_flight_count,
                :sorties,
                :emergency_land_count,
                :captured_count,
                :alive_streak,
                :kill_streak,
                :plane
  
  def self.parse(pilot_stats)
    mission = self.new
    mission.name                        = pilot_stats[0][7..-1].strip
    mission.score                       = pilot_stats[1][8..-1].to_i
    mission.last_state                  = pilot_stats[2][8..-1].strip
    mission.enemy_aircraft_kill         = pilot_stats[3][22..-1].to_i
    mission.enemy_static_aircraft_kill  = pilot_stats[4][29..-1].to_i
    mission.enemy_tank_kill             = pilot_stats[5][18..-1].to_i
    mission.enemy_car_kill              = pilot_stats[6][17..-1].to_i
    mission.enemy_artillery_kill        = pilot_stats[7][23..-1].to_i
    mission.enemy_AAA_kill              = pilot_stats[8][17..-1].to_i
    mission.enemy_wagon_kill            = pilot_stats[9][19..-1].to_i
    mission.enemy_ship_kill             = pilot_stats[10][18..-1].to_i
    mission.friend_aircraft_kill        = pilot_stats[11][23..-1].to_i
    mission.friend_static_aircraft_kill = pilot_stats[12][30..-1].to_i
    mission.friend_tank_kill            = pilot_stats[13][19..-1].to_i
    mission.friend_car_kill             = pilot_stats[14][18..-1].to_i
    mission.friend_artillery_kill       = pilot_stats[15][24..-1].to_i
    mission.friend_AAA_kill             = pilot_stats[16][18..-1].to_i
    mission.friend_wagon_kill           = pilot_stats[17][20..-1].to_i
    mission.friend_ship_kill            = pilot_stats[18][19..-1].to_i
    mission.fire_bullets                = pilot_stats[19][16..-1].to_i
    mission.hit_bullets                 = pilot_stats[20][15..-1].to_i
    mission.hit_air_bullets             = pilot_stats[21][18..-1].to_i
    mission.fire_roskets                = pilot_stats[22][16..-1].to_i
    mission.hit_roskets                 = pilot_stats[23][15..-1].to_i
    mission.fire_bombs                  = pilot_stats[24][14..-1].to_i
    mission.hit_bombs                   = pilot_stats[25][13..-1].to_i
    mission.land_count = mission.kia_count = mission.mia_count = mission.left_count = mission.hit_the_silk_count = mission.emergency_land_count = mission.captured_count = mission.in_flight_count = 0

    case mission.last_state
    when "Landed at Airfield":
      mission.land_count = 1
    when "KIA":
      mission.kia_count = 1
    when "MIA":
      mission.mia_count = 1
    when "Left the Game":
      mission.left_count = 1
    when "Hit the Silk":
      mission.hit_the_silk_count = 1
    when "Captured":
      mission.captured_count = 1
    when "Emergency Landed"
      mission.emergency_land_count = 1
    when "In Flight":
      mission.in_flight_count = 1
    end
    mission.sorties = 1
    case mission.dead_or_alive
    when "Dead":
      mission.alive_streak = 0
      mission.kill_streak = 0
    when "Alive":
      mission.kill_streak ||= 0
      mission.alive_streak = 1
      mission.kill_streak += mission.enemy_aircraft_kill
    end
    mission
  end
  
  def dead_or_alive
    case @last_state
    when "Landed at Airfield":
      "Alive"
    when "Hit the Silk":
      "Alive"
    when "Captured":
      "Alive"
    when "Emergency Landed":
      "Alive"
    when "In Flight":
      "Alive"
    when "Left the Game":
      "Dead"
    else "Dead"
    end
  end
  
  def bullet_accuracy
    return 0 if @fire_bullets == 0
    ((@hit_bullets.to_f / @fire_bullets)*100).to_i
  end
  
  def survived_count
    @captured_count + @land_count + @emergency_land_count + @hit_the_silk_count + @in_flight_count
  end
  
  def survivability
    return 0 if @sorties == 0
    ((survived_count.to_f / @sorties)*100).to_i
  end
    
  def +(e)
    r = PilotMissionLog.new
    r.name                        = e.name
    r.score                       = @score + e.score
    r.last_state                  = e.last_state 
    r.enemy_aircraft_kill         = @enemy_aircraft_kill + e.enemy_aircraft_kill
    r.enemy_static_aircraft_kill  = @enemy_static_aircraft_kill + e.enemy_static_aircraft_kill
    r.enemy_tank_kill             = @enemy_tank_kill + e.enemy_tank_kill
    r.enemy_car_kill              = @enemy_car_kill + e.enemy_car_kill
    r.enemy_artillery_kill        = @enemy_artillery_kill + e.enemy_artillery_kill
    r.enemy_AAA_kill              = @enemy_AAA_kill + e.enemy_AAA_kill
    r.enemy_wagon_kill            = @enemy_wagon_kill + e.enemy_wagon_kill
    r.enemy_ship_kill             = @enemy_ship_kill + e.enemy_ship_kill
    r.friend_aircraft_kill        = @friend_aircraft_kill + e.friend_aircraft_kill
    r.friend_static_aircraft_kill = @friend_static_aircraft_kill + e.friend_static_aircraft_kill
    r.friend_tank_kill            = @friend_tank_kill + e.friend_tank_kill
    r.friend_car_kill             = @friend_car_kill + e.friend_car_kill
    r.friend_artillery_kill       = @friend_artillery_kill + e.friend_artillery_kill
    r.friend_AAA_kill             = @friend_AAA_kill + e.friend_AAA_kill
    r.friend_wagon_kill           = @friend_wagon_kill + e.friend_wagon_kill
    r.friend_ship_kill            = @friend_ship_kill + e.friend_ship_kill
    r.fire_bullets                = @fire_bullets + e.fire_bullets
    r.hit_bullets                 = @hit_bullets + e.hit_bullets
    r.hit_air_bullets             = @hit_air_bullets + e.hit_air_bullets
    r.fire_roskets                = @fire_roskets + e.fire_roskets
    r.hit_roskets                 = @hit_roskets + e.hit_roskets
    r.fire_bombs                  = @fire_bombs + e.fire_bombs
    r.hit_bombs                   = @hit_bombs + e.hit_bombs
    r.mia_count                   = @mia_count + e.mia_count
    r.kia_count                   = @kia_count + e.kia_count
    r.land_count                  = @land_count + e.land_count
    r.hit_the_silk_count          = @hit_the_silk_count + e.hit_the_silk_count
    r.sorties                     = @sorties + e.sorties
    r.emergency_land_count        = @emergency_land_count + e.emergency_land_count
    r.captured_count              = @captured_count + e.captured_count
    r.in_flight_count             = @in_flight_count + e.in_flight_count
    r.left_count                  = @left_count + e.left_count
    
    case e.dead_or_alive
    when "Dead":
      r.alive_streak = 0
      r.kill_streak = 0
    when "Alive":
      r.alive_streak = @alive_streak + e.alive_streak
      r.kill_streak = @kill_streak + e.kill_streak
    end
    r
  end
end

class PilotMissionParsed
  attr_accessor :name, :last_state, :fighter_kills, :bomber_kills, :art, :arm, :car, :trn, :plane
  def initialize(pilot)
    pilot =~ /^(.+?):.+?\s(\w.*\w)\s+Fgt: \d+\+ (\d+) Bmb: \d+\+ (\d+) Gnd: \d+ Art: (\d+) Arm: (\d+) Shp: 0\+ \d+ Car: (\d+) Trn:\s*(\d+).*Oth: 0 (.*)\s*$/
    @name = $1
    @last_state = $2
    @fighter_kills = $3.to_i
    @bomber_kills = $4.to_i
    @art = $5.to_i
    @arm = $6.to_i
    @car = $7.to_i
    @trn = $8.to_i
    @plane = $9
  end
  
  def log_pilot
    r = PilotMissionLog.new
    r.name = @name
    r.enemy_aircraft_kill = @fighter_kills + @bomber_kills
    r.enemy_tank_kill = @arm
    r.enemy_artillery_kill = @art
    r.enemy_car_kill = @car
    r.enemy_wagon_kill = @trn
    r.plane = @plane
    
    r.land_count = r.kia_count = r.mia_count = r.left_count = r.hit_the_silk_count = r.emergency_land_count = r.captured_count = r.in_flight_count = 0
    case @last_state
    when "Landed":
      r.land_count = 1
      r.last_state = "Landed at Airfield"
    when "KIA":
      r.kia_count = 1
      r.last_state = "KIA"
    when "MIA":
      r.mia_count = 1
      r.last_state = "MIA"
    when "Disconnected":
      r.left_count = 1
      r.last_state = "Left the Game"
    when "Bailed":
      r.hit_the_silk_count = 1
      r.last_state = "Hit the Silk"
    when "Emergency landi"
      r.emergency_land_count = 1
      r.last_state = "Emergency Landed"
    when "In Flight":
      r.in_flight_count = 1
    end    
    
    r.sorties = 1
    case r.dead_or_alive
    when "Dead":
      r.alive_streak = 0
      r.kill_streak = 0
    when "Alive":
      r.kill_streak ||= 0
      r.alive_streak = 1
      r.kill_streak += r.enemy_aircraft_kill
    end
    
    r.score = 0
    r.enemy_ship_kill = 0
    r.enemy_static_aircraft_kill = 0
    r.enemy_AAA_kill = 0
    r.friend_aircraft_kill = 0
    r.friend_static_aircraft_kill = 0
    r.friend_tank_kill = 0
    r.friend_car_kill = 0
    r.friend_artillery_kill = 0
    r.friend_AAA_kill = 0
    r.friend_wagon_kill = 0
    r.friend_ship_kill = 0
    r.fire_bullets = 0
    r.hit_bullets = 0
    r.hit_air_bullets = 0
    r.fire_roskets = 0
    r.hit_roskets = 0
    r.fire_bombs = 0
    r.hit_bombs = 0
    r.land_count= 0
    r.kia_count= 0
    r.mia_count= 0
    r.left_count= 0
    r.hit_the_silk_count= 0
    r.in_flight_count= 0
    r.sorties= 0
    r.emergency_land_count= 0
    r.captured_count= 0
    r.alive_streak= 0
    r.kill_streak= 0
    return r
  end
end

class MissionLog
  attr_accessor :mission
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
      else
        @mission << parsed_pilot.log_pilot
      end
    end
    
    parse_log
    @mission << @lasted_minutes
    self
  end
private
  def parse_log
    reference_point = Chronic.parse("midnight")
    started_at = Chronic.parse(@log[2][0..7], :now => reference_point)
    ended_at = Chronic.parse(@log[-2][0..7], :now => reference_point)
    @lasted_minutes = (ended_at-started_at).to_i/60
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
end

File.open(ARGV[0], 'r') do |file|
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
engine = Haml::Engine.new(File.read("template.html.haml"))

File.open("output.html", "w") do |file|
  file.write engine.render(self)
end