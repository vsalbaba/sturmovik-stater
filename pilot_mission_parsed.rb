class PilotMissionParsed
  attr_accessor :name, :last_state, :fighter_kills, :bomber_kills, :art, :arm, :car, :trn, :plane, :side
  def initialize(pilot, side = 'Unknown')
    pilot =~ /^(.+?):.+?\s(\w.*\w)\s+Fgt: \d+\+ (\d+) Bmb: \d+\+ (\d+) Gnd: \d+ Art: (\d+) Arm: (\d+) Shp: 0\+ \d+ Car:\s*(\d+) Trn:\s*(\d+).*Oth: 0 (.*)\s*$/
    @name = $1
    @last_state = $2
    @fighter_kills = $3.to_i
    @bomber_kills = $4.to_i
    @art = $5.to_i
    @arm = $6.to_i
    @car = $7.to_i
    @trn = $8.to_i
    @plane = $9
    @side = side
    rewrite_last_state
    self
  end

  def rewrite_last_state
    @last_state = case @last_state
    when "Landed" then
      "Landed at Airfield"
    when "Disconnected" then
      "Left the Game"
    when "Bailed" then
      "Hit the Silk"
    when "Emergency landi" then
      "Emergency Landed"
    else
      @last_state
    end
  end

  def log_pilot
    rewrite_last_state

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
    when "Landed at Airfield" then
      r.land_count = 1
    when "KIA" then
      r.kia_count = 1
    when "MIA" then
      r.mia_count = 1
    when "Left the Game" then
      r.left_count = 1
    when "Hit the Silk" then
      r.hit_the_silk_count = 1
    when "Emergency Landed"
      r.emergency_land_count = 1
    when "In Flight" then
      r.in_flight_count = 1
    end
    r.last_state = @last_state

    r.sorties = 1
    case r.dead_or_alive
    when "Dead" then
      r.alive_streak = 0
      r.kill_streak = 0
    when "Alive" then
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
    return r
  end
end

