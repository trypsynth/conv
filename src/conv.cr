enum UnitType
  Temperature
  Length
end

class Unit
  getter symbol : String
  getter type : UnitType
  alias Converter = Float64 -> Float64

  def initialize(@symbol : String, @type : UnitType, @to_base : Converter, @from_base : Converter)
  end

  def to_base(value : Float64) : Float64
    @to_base.call(value)
  end

  def from_base(value : Float64) : Float64
    @from_base.call(value)
  end
end

module UnitConverter
  UNITS = {
    # Temperature, base = Kelvin
    "k"  => Unit.new("k", UnitType::Temperature, ->(k : Float64) { k }, ->(k : Float64) { k }),
    "c"  => Unit.new("c", UnitType::Temperature, ->(c : Float64) { c + 273.15 }, ->(k : Float64) { k - 273.15 }),
    "f"  => Unit.new("f", UnitType::Temperature, ->(f : Float64) { (f - 32.0) * 5.0 / 9.0 + 273.15 }, ->(k : Float64) { (k - 273.15) * 9.0 / 5.0 + 32.0 }),
    "r" => Unit.new("r", UnitType::Temperature, ->(r : Float64) { r * 5.0 / 9.0 }, ->(k : Float64) { k * 9.0 / 5.0 }),
    "de" => Unit.new("de", UnitType::Temperature, ->(de : Float64) { 373.15 - de * 2.0 / 3.0 }, ->(k : Float64) { (373.15 - k) * 3.0 / 2.0 }),
    # Length, base = meter
    "m"  => Unit.new("m", UnitType::Length, ->(v : Float64) { v }, ->(v : Float64) { v }),
    "km" => Unit.new("km", UnitType::Length, ->(v : Float64) { v * 1000 }, ->(v : Float64) { v / 1000 }),
    "dm" => Unit.new("dm", UnitType::Length, ->(v : Float64) { v * 0.1 }, ->(v : Float64) { v / 0.1 }),
    "cm" => Unit.new("cm", UnitType::Length, ->(v : Float64) { v * 0.01 }, ->(v : Float64) { v / 0.01 }),
    "mm" => Unit.new("mm", UnitType::Length, ->(v : Float64) { v * 0.001 }, ->(v : Float64) { v / 0.001 }),
    "um" => Unit.new("um", UnitType::Length, ->(v : Float64) { v * 1e-6 }, ->(v : Float64) { v / 1e-6 }),
    "nm" => Unit.new("nm", UnitType::Length, ->(v : Float64) { v * 1e-9 }, ->(v : Float64) { v / 1e-9 }),
    "in" => Unit.new("in", UnitType::Length, ->(v : Float64) { v * 0.0254 }, ->(v : Float64) { v / 0.0254 }),
    "ft" => Unit.new("ft", UnitType::Length, ->(v : Float64) { v * 0.3048 }, ->(v : Float64) { v / 0.3048 }),
    "yd" => Unit.new("yd", UnitType::Length, ->(v : Float64) { v * 0.9144 }, ->(v : Float64) { v / 0.9144 }),
    "mi" => Unit.new("mi", UnitType::Length, ->(v : Float64) { v * 1609.344 }, ->(v : Float64) { v / 1609.344 }),
    "nmi" => Unit.new("nmi", UnitType::Length, ->(v : Float64) { v * 1852.0 }, ->(v : Float64) { v / 1852.0 }),
  } of String => Unit

  def self.convert(value : Float64, from : Unit, to : Unit) : Float64
    raise "Incompatible units" if from.type != to.type
    to.from_base(from.to_base(value))
  end

  def self.validate_unit(unit : String) : Unit
    UNITS[unit.downcase]? || (raise "Invalid unit '#{unit}'")
  end

  def self.build_usage : String
    String.build do |sb|
      sb << "Usage: conv <value> <from_unit> <to_unit>\n"
      sb << "Available units:\n"
      grouped = UNITS.values.group_by(&.type)
      [UnitType::Temperature, UnitType::Length].each do |type|
        if units = grouped[type]?
          symbols = units.map(&.symbol).sort.join(", ")
          sb << "\t#{type}: #{symbols}\n"
        end
      end
    end
  end
end

def main
  if ARGV.size != 3
    STDERR.puts UnitConverter.build_usage
    exit 1
  end
  begin
    input_value = ARGV[0].to_f
    from = UnitConverter.validate_unit(ARGV[1])
    to = UnitConverter.validate_unit(ARGV[2])
    result = UnitConverter.convert(input_value, from, to)
    puts "#{input_value} #{from.symbol} is #{result} #{to.symbol}"
  rescue e
    STDERR.puts "conv: error: #{e.message}"
    STDERR.puts
    STDERR.puts UnitConverter.build_usage
    exit 1
  end
end

main
