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
        if pilot.last_state == "Left the Game" then
          pilot.last_state = parsed_pilot.last_state unless parsed_pilot.last_state == "Disconnected"
        end
      else
        @mission << parsed_pilot.log_pilot
      end
    end
    
    parse_log

    @mission << "#{@real_world_date}, #{@lasted_minutes}"
    return self
  end

private
  def parse_log
    reference_point = Chronic.parse("midnight")
    started_at = Chronic.parse(@log[2][0..7], :now => reference_point)
    ended_at = Chronic.parse(@log[-2][0..7], :now => reference_point)
    @real_world_date = @log[0][(@log[0].index("[").next)..(@log[0].index("]").pred-3)]
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
