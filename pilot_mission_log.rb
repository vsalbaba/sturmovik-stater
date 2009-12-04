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
                :score_streak,
                :best_alive_streak,
                :best_kill_streak,
                :best_score_streak,
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
    when "Landed at Airfield" then
      mission.land_count = 1
    when "KIA" then
      mission.kia_count = 1
    when "MIA" then
      mission.mia_count = 1
    when "Left the Game"then
      mission.left_count = 1
    when "Hit the Silk"then
      mission.hit_the_silk_count = 1
    when "Captured"then
      mission.captured_count = 1
    when "Emergency Landed"
      mission.emergency_land_count = 1
    when "In Flight"then
      mission.in_flight_count = 1
    end
    mission.sorties = 1
    case mission.dead_or_alive
    when "Dead"then
      mission.alive_streak = 0
      mission.kill_streak = 0
      mission.score_streak = 0
      mission.best_kill_streak = 0
      mission.best_alive_streak = 0
      mission.best_score_streak = 0

    when "Alive"then
      mission.alive_streak = 1
      mission.kill_streak = mission.enemy_aircraft_kill
      mission.score_streak = mission.score
      mission.best_score_streak = mission.score
      mission.best_alive_streak = 1
      mission.best_kill_streak = mission.kill_streak
    end
    mission
  end

  def dead_or_alive
    case @last_state
    when "Landed at Airfield"then
      "Alive"
    when "Hit the Silk"then
      "Alive"
    when "Captured"then
      "Alive"
    when "Emergency Landed" then
      "Alive"
    when "In Flight" then
      "Alive"
    when "Left the Game" then
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
    r.best_alive_streak           = 0
    r.best_kill_streak            = 0
    r.best_score_streak           = 0
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
    r.best_alive_streak           = @best_alive_streak
    r.best_kill_streak            = @best_kill_streak
    r.best_score_streak           = @best_score_streak

    case e.dead_or_alive
    when "Dead" then
      r.score_streak = 0
      r.alive_streak = 0
      r.kill_streak = 0
    when "Alive" then
      r.alive_streak = @alive_streak + e.alive_streak

      if r.alive_streak > r.best_alive_streak
        r.best_alive_streak = r.alive_streak
      end

      r.kill_streak = @kill_streak + e.kill_streak

      if r.kill_streak > r.best_kill_streak
        r.best_kill_streak = r.kill_streak
      end

      # r.score_streak = @score_streak + e.score_streak
      # if r.score_streak > r.best_score_streak
      #   r.best_score_streak = r.score_streak
      # end
    end
    r
  end
end

