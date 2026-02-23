require "option_parser"

abstract class Unit
  getter symbol : String
  alias Converter = Float64 -> Float64

  def initialize(@symbol : String, @to_base : Converter, @from_base : Converter)
  end

  def to_base(value : Float64) : Float64
    @to_base.call(value)
  end

  def from_base(value : Float64) : Float64
    @from_base.call(value)
  end
end

class TemperatureUnit < Unit
end

class LengthUnit < Unit
end

module UnitConverter
  UNITS = {
    # Temperature, base = Kelvin
    "k"  => TemperatureUnit.new("k", ->(k : Float64) { k }, ->(k : Float64) { k }),
    "c"  => TemperatureUnit.new("c", ->(c : Float64) { c + 273.15 }, ->(k : Float64) { k - 273.15 }),
    "f"  => TemperatureUnit.new("f", ->(f : Float64) { (f - 32.0) * 5.0 / 9.0 + 273.15 }, ->(k : Float64) { (k - 273.15) * 9.0 / 5.0 + 32.0 }),
    "r"  => TemperatureUnit.new("r", ->(r : Float64) { r * 5.0 / 9.0 }, ->(k : Float64) { k * 9.0 / 5.0 }),
    "de" => TemperatureUnit.new("de", ->(de : Float64) { 373.15 - de * 2.0 / 3.0 }, ->(k : Float64) { (373.15 - k) * 3.0 / 2.0 }),
    # Length, base = meter
    "m"   => LengthUnit.new("m", ->(v : Float64) { v }, ->(v : Float64) { v }),
    "km"  => LengthUnit.new("km", ->(v : Float64) { v * 1000 }, ->(v : Float64) { v / 1000 }),
    "dm"  => LengthUnit.new("dm", ->(v : Float64) { v * 0.1 }, ->(v : Float64) { v / 0.1 }),
    "cm"  => LengthUnit.new("cm", ->(v : Float64) { v * 0.01 }, ->(v : Float64) { v / 0.01 }),
    "mm"  => LengthUnit.new("mm", ->(v : Float64) { v * 0.001 }, ->(v : Float64) { v / 0.001 }),
    "um"  => LengthUnit.new("um", ->(v : Float64) { v * 1e-6 }, ->(v : Float64) { v / 1e-6 }),
    "nm"  => LengthUnit.new("nm", ->(v : Float64) { v * 1e-9 }, ->(v : Float64) { v / 1e-9 }),
    "in"  => LengthUnit.new("in", ->(v : Float64) { v * 0.0254 }, ->(v : Float64) { v / 0.0254 }),
    "ft"  => LengthUnit.new("ft", ->(v : Float64) { v * 0.3048 }, ->(v : Float64) { v / 0.3048 }),
    "yd"  => LengthUnit.new("yd", ->(v : Float64) { v * 0.9144 }, ->(v : Float64) { v / 0.9144 }),
    "mi"  => LengthUnit.new("mi", ->(v : Float64) { v * 1609.344 }, ->(v : Float64) { v / 1609.344 }),
    "nmi" => LengthUnit.new("nmi", ->(v : Float64) { v * 1852.0 }, ->(v : Float64) { v / 1852.0 }),
  } of String => Unit

  def self.convert(value : Float64, from : Unit, to : Unit) : Float64
    raise "Incompatible units" unless from.class == to.class
    to.from_base(from.to_base(value))
  end

  def self.validate_unit(unit : String) : Unit
    UNITS[unit.downcase]? || (raise "Invalid unit '#{unit}'")
  end

  def self.build_unit_list : String
    grouped = UNITS.values.group_by(&.class)
    String.build do |sb|
      sb << "Usage: conv <value> <from_unit> <to_unit>\n"
      sb << "Available units:\n"
      grouped.keys.sort_by(&.name).each do |klass|
        symbols = grouped[klass].map(&.symbol).sort.join(", ")
        sb << "  #{klass.name}: #{symbols}\n"
      end
    end
  end
end

def perform_conversion(parts : Array(String))
  value = parts[0].to_f
  from = UnitConverter.validate_unit(parts[1])
  to = UnitConverter.validate_unit(parts[2])
  result = UnitConverter.convert(value, from, to)
  puts "#{value} #{from.symbol} is #{result} #{to.symbol}"
rescue e
  puts "Error: #{e.message}"
end

def run_repl
  puts "Conv REPL ready."
  loop do
    print "> "
    line = gets
    break unless line
    line = line.strip
    parts = line.split
    if parts.size != 3
      puts "Invalid input. Expected: <value> <from> <to>"
      next
    end
    perform_conversion parts
  end
end

list_units = false
repl_mode = false
show_help = false
parser = OptionParser.parse do |parser|
  parser.banner = <<-TEXT
  Usage: conv [options] <value> <from_unit> <to_unit>

  Options:
  TEXT
  parser.on("-l", "--list", "List all available units") do
    list_units = true
  end
  parser.on("-i", "--repl", "Start interactive REPL mode") do
    repl_mode = true
  end
  parser.on("-h", "--help", "Show this help and exit") do
    show_help = true
  end
end
if list_units
  puts UnitConverter.build_unit_list
  exit 0
end
if show_help
  puts parser
  exit 0
end
if repl_mode
  run_repl
  exit 0
end
if ARGV.size != 3
  STDERR.puts parser
  exit 1
end
perform_conversion ARGV
