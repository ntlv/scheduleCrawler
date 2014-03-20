class Event
    attr_reader :beginsAt, :endsAt, :location
    
    def initialize(beginsAt = Time.now, endsAt = beginsAt + 60*60, location = "Somewhere")
        @beginsAt = beginsAt
        @endsAt = endsAt
        @location = location
    end
    
    def overlaps(otherEvent)
        not(@beginsAt > otherEvent.endsAt ||  @endsAt < otherEvent.beginsAt)
    end
    
    def noOverlapWithDate(dateAndTime)
        not(@beginsAt < dateAndTime &&  @endsAt > dateAndTime)
    end
    
    def isLocation(num)
        @location == num
    end
    
    def sameLocation(otherEvent)
        return @location == otherEvent.location
    end
    
    def to_s
        "Event { " + @location.to_s + " from " + @beginsAt.to_s + " until " + @endsAt.to_s  + " }"
    end
end

def buildUrl(prefix, suffix, classrooms)
    url = String.new(prefix)
    url += classrooms[0]
    delimiter = "%2C"
    arr = classrooms[1..classrooms.size]
    arr.each { |a| url += delimiter +  a }
    url + suffix
end
