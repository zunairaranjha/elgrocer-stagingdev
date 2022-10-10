class DeliveryZone::ImporterService
  attr_reader :kml

  def initialize(file)
    @kml = File.open(file) { |f| Nokogiri::XML(f) { |config| config.strict } }
  end

  def perform
    DeliveryZone.create(
      coordinates: polygon,
      name: name,
      color: color,
      width: width
    )
  end

  def polygon
    "POLYGON((#{coordinates}))"
  end

  private

  def coordinates
    kml.css('coordinates').first.children.first.to_s.strip.lines.map do |line| 
      line.strip.split(' ')
        .map{ |i| i.split(',') }
        .map {|p| "#{p[0]} #{ p[1]}"}
    end.compact.join(',')
  end

  def name
    kml.css('Placemark name').first.children.first.to_s
  end

  def color
    kml.css('LineStyle color').first.children.first.to_s
  end

  def width
    kml.css('LineStyle width').first.children.first.to_s.to_i
  end
end
