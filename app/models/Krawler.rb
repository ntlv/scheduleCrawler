require 'open-uri'
require 'csv'
require 'enumerator'
require_relative 'superEvent'
require_relative 'event'



class Krawler
    
    @@urlprefix = "https://se.timeedit.net/web/uu/db1/schema/ri.csv?sid=3&p=0.d%2C1.d&fw=t&objects="
    @@urlsuffix = "&ox=0&types=0&fe=0"
    
    @@classrooms_building1 = {
    1111 => "250742.211",
    1112 => "250770.211",
    1113 => "250771.211",
    1145 => "250772.211",
    1146 => "250773.211",
    
    1211 => "250774.211",
    1212 => "250775.211",
    1213 => "250776.211",
    1245 => "250777.211",
    
    1311 => "250778.211",
    1312 => "250709.211",
    1313 => "250710.211"
    }
    
    @@classrooms_building2 = {
    
    2214 => "250781.211",
    2215 => "250782.211",
    2244 => "250783.211",
    2245 => "250784.211",
    2247 => "250785.211",
    2314 => "250712.211",
    2315 => "250708.211",
    2344 => "250786.211",
    2345 => "250787.211",
    2347 => "250788.211"
    
    }
    
    def buildUrl(prefix, suffix, classrooms)
        url = String.new(prefix)
        url += classrooms[0]
        delimiter = "%2C"
        arr = classrooms[1..classrooms.size]
        arr.each { |a| url += delimiter +  a }
        url + suffix
    end
    
    def initialize
        @houses = [ @@classrooms_building1, @@classrooms_building2]
    end
    
    def hello
        "hello"
    end
    
    def get_times
        outputArray = []
        outputArray << "\nKlassrum som är delvis lediga under dagen:"
        
        nonBookedOutArray = []
        nonBookedOutArray << "\nKlassrum som är lediga hela dagen:"
        
        # for testing, small sample csv
        #house1 = "time.csv"
        nonBookedClassRooms = []
        
        @houses.each { |houseRoomCollection| nonBookedClassRooms.concat houseRoomCollection.keys }
        
        @houses.each do |houseRoomCollection|
            
            houseNumber = buildUrl(@@urlprefix, @@urlsuffix, houseRoomCollection.values)
            
            #puts "fetching csv from " + houseNumber
            
            p = get_csv(houseNumber)
            
            #puts p
            
            p1 = p.gsub('"', '')
            csv = CSV.parse(p1)
            
            #0, 1, 2, 3 tider
            # 8 lokal
            
            
            busyTimes = parse_csv(csv)
            
            if busyTimes.length > 1 then
                busyTimes.sort! {|a,b| a.location <=> b.location}
                superEvents = aggregate_times(busyTimes)
                
                
                
                superEvents.each do |sE|
                    puts sE
                    freeTimes = sE.obtainSortedFreeTimes
                    if freeTimes.length > 0 then
                        outputArray <<  $/*2 + sE.location.to_s
                        outputArray << "-" * 20
                        freeTimes.each_slice(2) do |s, e|
                            outputArray << (s.strftime("%H:%M") + " - " + e.strftime("%H:%M"))
                        end
                        outputArray << "-" * 20
                        nonBookedClassRooms.delete(sE.location)
                    end
                end
            end
        end
        
        if nonBookedClassRooms.length > 0 then
            nonBookedClassRooms.sort.each_with_index do |nr, index|
                nonBookedOutArray << if (index.modulo 3).zero?  then $/ + nr.to_s else nr.to_s end
            end
        end
    
        return outputArray.concat(nonBookedOutArray).join($/)
    end
    
    private # here goes the internal things
    
    def get_csv(houseNumber)
        csv_houseNumber = open(houseNumber).read.lines.to_a[3..-1].join('\n')
        p = csv_houseNumber.split('\n').map do |line|
            isInsiseQuote = false
            line.scan(/./).map do |character|
                
                if character == '"' then
                    isInsiseQuote = !isInsiseQuote
                    '"'
                    elsif character == "," && isInsiseQuote == true then
                    ''
                    else
                    character
                end
            end.join
        end.join("\n")
    end
    
    def parse_csv(csv)
        busyTimes = []
        csv.to_a[1..-1].each do |e|
            e[8].split(' ').each do |location|
                loc = location.to_i
                if loc != 0 then
                    start = DateTime.parse(e[0] + ", " + e[1])
                    endT = DateTime.parse(e[2] + ", " +e[3])
                    busyTimes << Event.new(start, endT, loc)
                end
            end
        end
        busyTimes
    end
    
    def aggregate_times(events)
        superEvents = []
        superE = SuperEvent.new(events[0].location)
        events.each do |ev|
            if not superE.addEvent(ev) then
                superEvents << superE
                superE = SuperEvent.new(ev.location)
                superE.addEvent(ev)
            end
        end
        
        if not superEvents[-1] == superE then superEvents << superE end
        superEvents
    end
end
