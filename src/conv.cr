require "option_parser"

class IncompatibleUnitError < Exception; end

class InvalidUnitError < Exception; end

enum UnitKind
  Temperature
  Length
end

record Unit, symbol : String, kind : UnitKind, to_base : (Float64 -> Float64), from_base : (Float64 -> Float64) do
  def convert(value : Float64, to other : Unit) : Float64
    raise IncompatibleUnitError.new("Cannot convert #{kind} to #{other.kind}") unless kind == other.kind
    other.from_base.call(to_base.call(value))
  end
end

module Units
  private def self.temp(symbol, to_base, from_base)
    Unit.new(symbol, :temperature, to_base, from_base)
  end

  private def self.length(symbol, factor)
    Unit.new(symbol, :length, ->(v : Float64) { v * factor }, ->(v : Float64) { v / factor })
  end

  IDENTITY = ->(v : Float64) { v }

  ALL = {
    # Temperature (base = Kelvin)
    "k"  => temp("k", IDENTITY, IDENTITY),
    "c"  => temp("c", ->(v : Float64) { v + 273.15 }, ->(v : Float64) { v - 273.15 }),
    "f"  => temp("f", ->(v : Float64) { (v - 32) * 5 / 9 + 273.15 }, ->(v : Float64) { (v - 273.15) * 9 / 5 + 32 }),
    "r"  => temp("r", ->(v : Float64) { v * 5 / 9 }, ->(v : Float64) { v * 9 / 5 }),
    "de" => temp("de", ->(v : Float64) { 373.15 - v * 2 / 3 }, ->(v : Float64) { (373.15 - v) * 3 / 2 }),
    # Length (base = meter)
    "m"   => length("m", 1.0),
    "km"  => length("km", 1000.0),
    "dm"  => length("dm", 0.1),
    "cm"  => length("cm", 0.01),
    "mm"  => length("mm", 0.001),
    "um"  => length("um", 1e-6),
    "nm"  => length("nm", 1e-9),
    "in"  => length("in", 0.0254),
    "ft"  => length("ft", 0.3048),
    "yd"  => length("yd", 0.9144),
    "mi"  => length("mi", 1609.344),
    "nmi" => length("nmi", 1852.0),
  }

  def self.find(name : String) : Unit
    ALL[name.downcase]? || raise InvalidUnitError.new("Invalid unit '#{name}'")
  end

  def self.list
    String.build do |io|
      io << "Available units:\n"
      ALL.values.group_by(&.kind).each do |kind, units|
        symbols = units.map(&.symbol).sort!.join(", ")
        io << "  #{kind}: #{symbols}\n"
      end
    end
  end
end

def perform_conversion(args : Array(String))
  value = args[0].to_f
  from = Units.find(args[1])
  to = Units.find(args[2])
  result = from.convert(value, to: to)
  puts "#{value} #{from.symbol} is #{"%.4f" % result} #{to.symbol}"
rescue ex
  abort "Error: #{ex.message}"
end

def run_repl
  puts "Conv REPL ready."
  loop do
    print "> "
    line = gets || break
    parts = line.strip.split
    unless parts.size == 3
      puts "Expected: <value> <from> <to>"
      next
    end
    perform_conversion(parts)
  end
end

list_units = false
repl_mode = false
parser = OptionParser.parse do |p|
  p.banner = "Usage: conv [options] <value> <from_unit> <to_unit>\n\nOptions:"
  p.on("-l", "--list", "List all available units") { list_units = true }
  p.on("-i", "--repl", "Start interactive REPL mode") { repl_mode = true }
  p.on("-h", "--help", "Show this help and exit") { puts p; exit }
end
case
when list_units     then puts Units.list
when repl_mode      then run_repl
when ARGV.size == 3 then perform_conversion(ARGV)
else                     abort parser
end
