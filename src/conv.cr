require "option_parser"

class IncompatibleUnitError < Exception
end

class InvalidUnitError < Exception
end

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

  def convert(value : Float64, to : Unit) : Float64
    raise IncompatibleUnitError.new unless self.class == to.class
    to.from_base(to_base(value))
  end
end

class TemperatureUnit < Unit
end

class LengthUnit < Unit
end

module Units
  private IDENTITY = ->(v : Float64) { v }

  private def self.scale(symbol : String, factor : Float64)
    LengthUnit.new(symbol, ->(v : Float64) { v * factor }, ->(v : Float64) { v / factor })
  end

  UNITS = {
    # Temperature (base = Kelvin)
    "k"  => TemperatureUnit.new("k", IDENTITY, IDENTITY),
    "c"  => TemperatureUnit.new("c", ->(c : Float64) { c + 273.15 }, ->(k : Float64) { k - 273.15 }),
    "f"  => TemperatureUnit.new("f", ->(f : Float64) { (f - 32.0) * 5.0 / 9.0 + 273.15 }, ->(k : Float64) { (k - 273.15) * 9.0 / 5.0 + 32.0 }),
    "r"  => TemperatureUnit.new("r", ->(r : Float64) { r * 5.0 / 9.0 }, ->(k : Float64) { k * 9.0 / 5.0 }),
    "de" => TemperatureUnit.new("de", ->(de : Float64) { 373.15 - de * 2.0 / 3.0 }, ->(k : Float64) { (373.15 - k) * 3.0 / 2.0 }),
    # Length (base = meter)
    "m"   => scale("m", 1.0),
    "km"  => scale("km", 1000.0),
    "dm"  => scale("dm", 0.1),
    "cm"  => scale("cm", 0.01),
    "mm"  => scale("mm", 0.001),
    "um"  => scale("um", 1e-6),
    "nm"  => scale("nm", 1e-9),
    "in"  => scale("in", 0.0254),
    "ft"  => scale("ft", 0.3048),
    "yd"  => scale("yd", 0.9144),
    "mi"  => scale("mi", 1609.344),
    "nmi" => scale("nmi", 1852.0),
  } of String => Unit

  def self.find(name : String) : Unit
    UNITS[name.downcase]? || raise InvalidUnitError.new("Invalid unit '#{name}'")
  end

  def self.list : String
    grouped = UNITS.values.group_by(&.class)
    String.build do |sb|
      sb << "Available units:\n"
      grouped.keys.sort_by(&.name).each do |klass|
        symbols = grouped[klass].map(&.symbol).sort.join(", ")
        sb << "  #{klass.name}: #{symbols}\n"
      end
    end
  end
end

def perform_conversion(args : Array(String))
  value = Float64.new(args[0])
  from = Units.find(args[1])
  to = Units.find(args[2])
  result = from.convert(value, to)
  puts "#{value} #{from.symbol} is #{sprintf("%.4f", result)} #{to.symbol}"
rescue ex : Exception
  STDERR.puts "Error: #{ex.message}"
end

def run_repl
  puts "Conv REPL ready."
  loop do
    print "> "
    line = gets
    break unless line
    parts = line.strip.split
    if parts.size != 3
      puts "Expected: <value> <from> <to>"
      next
    end
    perform_conversion(parts)
  end
end

list_units = false
repl_mode = false
show_help = false
parser = OptionParser.parse do |p|
  p.banner = <<-TEXT
  Usage: conv [options] <value> <from_unit> <to_unit>

  Options:
  TEXT
  p.on("-l", "--list", "List all available units") { list_units = true }
  p.on("-i", "--repl", "Start interactive REPL mode") { repl_mode = true }
  p.on("-h", "--help", "Show this help and exit") { show_help = true }
end
if show_help
  puts parser
  exit 0
end
if list_units
  puts Units.list
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
