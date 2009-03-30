require 'rubygems'
require 'haml'
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
                :sorties,
                :emergency_land_count,
                :captured_count
  
  def parse(pilot_stats)
    @name                        = pilot_stats[1][7..-1].strip
    @score                       = pilot_stats[2][8..-1].to_i
    @last_state                  = pilot_stats[3][8..-1].strip
    @enemy_aircraft_kill         = pilot_stats[4][22..-1].to_i
    @enemy_static_aircraft_kill  = pilot_stats[5][29..-1].to_i
    @enemy_tank_kill             = pilot_stats[6][18..-1].to_i
    @enemy_car_kill              = pilot_stats[7][17..-1].to_i
    @enemy_artillery_kill        = pilot_stats[8][23..-1].to_i
    @enemy_AAA_kill              = pilot_stats[9][17..-1].to_i
    @enemy_wagon_kill            = pilot_stats[10][19..-1].to_i
    @enemy_ship_kill             = pilot_stats[11][18..-1].to_i
    @friend_aircraft_kill        = pilot_stats[12][23..-1].to_i
    @friend_static_aircraft_kill = pilot_stats[13][30..-1].to_i
    @friend_tank_kill            = pilot_stats[14][19..-1].to_i
    @friend_car_kill             = pilot_stats[15][18..-1].to_i
    @friend_artillery_kill       = pilot_stats[16][24..-1].to_i
    @friend_AAA_kill             = pilot_stats[17][18..-1].to_i
    @friend_wagon_kill           = pilot_stats[18][20..-1].to_i
    @friend_ship_kill            = pilot_stats[19][19..-1].to_i
    @fire_bullets                = pilot_stats[20][16..-1].to_i
    @hit_bullets                 = pilot_stats[21][15..-1].to_i
    @hit_air_bullets             = pilot_stats[22][18..-1].to_i
    @fire_roskets                = pilot_stats[23][16..-1].to_i
    @hit_roskets                 = pilot_stats[24][15..-1].to_i
    @fire_bombs                  = pilot_stats[25][14..-1].to_i
    @hit_bombs                   = pilot_stats[26][13..-1].to_i
    @land_count = @kia_count = @mia_count = @left_count = @hit_the_silk_count = @emergency_land_count = @captured_count = 0
 
    case @last_state
    when "Landed at Airfield":
      @land_count = 1
    when "KIA":
      @kia_count = 1
    when "MIA":
      @mia_count = 1
    when "Left the Game":
      @left_count = 1
    when "Hit the Silk":
      @hit_the_silk_count = 1
    when "Captured":
      @captured_count = 1
    when "Emergency Landed"
      @emergency_land_count = 1
    end
    @sorties = 1
    self
  end
  
  def dead_or_alive
    case @last_state
    when "Landed at Airfield":
      "Alive"
    when "Hit the Silk":
      "Alive"
    when "Captured":
      "Alive"
    when "Emergency Landed"
      "Alive"
    else "Dead"
    end
  
  def bullet_accuracy
    @hit_bullets.to_f / @fire_bullets
  end
  
  def survived_count
    @captured_count + @land_count + @emergency_land_count + @hit_the_silk_count
  end
  
  def survivability
    survived_count.to_f / @sorties
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
    r
  end
end

class MissionLog
  def parse(eventlog)
    stats = eventlog.slice(eventlog.index("-------------------------------------------------------\n")..(eventlog.index("============ eof ==============")-2))
    result = []
    while (pilot_stats = stats.slice!(0,27)).size == 27 do
      result << PilotMissionLog.new.parse(pilot_stats)
    end
    return result
  end
end

File.open(ARGV[0], 'r') do |file|
   stats = file.readlines
   @missions = []
   while stats.index("===== eventlog.lst =====\n") do
     stats.slice!(0..(stats.index("===== eventlog.lst =====\n")-1))
     mission = stats.slice!(0..stats.index("============ eof ==============\n"))
     mission[-1].rstrip!
    @missions << MissionLog.new.parse(mission)
  end
end

@overall = []
@missions.flatten.group_by(&:name).each_value do |value|
  @overall << value.inject {|sum, n| sum + n}
end

engine = Haml::Engine.new(File.read("template.html.haml"))

File.open("output.html", "w") do |file|
  file.write engine.render(self)
end