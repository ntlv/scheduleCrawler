class SuperEvent
    attr_reader :location
    
    def initialize(location = "Somewhere")
        @location = location
        @container = []
    end
    
    def addEvent(event)
        if event.location == location then
            @container << event.beginsAt
            @container << event.endsAt
            true
            else
            false
        end
    end
    
    def obtainSortedFreeTimes
        freeTime = []
        if @container != nil then
            if @container[0].strftime("%H") != "08" then
                freeTime << DateTime.parse("8:15")
                freeTime << @container[0]
            end
            @container[1..-1].each_slice(2) do |endT, startT|
                freeTime << endT
                if startT == nil then
                    freeTime << DateTime.parse("23:59")
                    else
                    freeTime << startT
                end
            end
        end
        freeTime.sort! {|a,b| a <=> b}
        
        freeTime
    end
    
    def to_s
        "SuperEvent {\n" + "\t" + @location.to_s + "\n at \n\t" + @container.to_s + "/n}"
    end
end
