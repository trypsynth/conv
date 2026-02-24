require "option_parser"

class IncompatibleUnitError < Exception; end

class InvalidUnitError < Exception; end

enum UnitKind
  Temperature
  Length
  Weight
  Volume
  Data
  Time
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

  private def self.weight(symbol, factor)
    Unit.new(symbol, :weight, ->(v : Float64) { v * factor }, ->(v : Float64) { v / factor })
  end

  private def self.volume(symbol, factor)
    Unit.new(symbol, :volume, ->(v : Float64) { v * factor }, ->(v : Float64) { v / factor })
  end

  private def self.data(symbol, factor)
    Unit.new(symbol, :data, ->(v : Float64) { v * factor }, ->(v : Float64) { v / factor })
  end

  private def self.time(symbol, factor)
    Unit.new(symbol, :time, ->(v : Float64) { v * factor }, ->(v : Float64) { v / factor })
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
    # Weight (base = gram)
    "g"  => weight("g", 1.0),
    "kg" => weight("kg", 1000.0),
    "mg" => weight("mg", 0.001),
    "ug" => weight("ug", 1e-6),
    "lb" => weight("lb", 453.592),
    "oz" => weight("oz", 28.3495),
    "st" => weight("st", 6350.29),
    "t"  => weight("t", 1000000.0),
    # Volume (base = liter)
    "l"    => volume("l", 1.0),
    "ml"   => volume("ml", 0.001),
    "cl"   => volume("cl", 0.01),
    "dl"   => volume("dl", 0.1),
    "gal"  => volume("gal", 3.78541),
    "qt"   => volume("qt", 0.946353),
    "pt"   => volume("pt", 0.473176),
    "cup"  => volume("cup", 0.236588),
    "floz" => volume("floz", 0.0295735),
    "tbsp" => volume("tbsp", 0.0147868),
    "tsp"  => volume("tsp", 0.00492892),
    # Data (base = byte)
    "b"   => data("b", 1.0),
    "kb"  => data("kb", 1000.0),
    "mb"  => data("mb", 1000000.0),
    "gb"  => data("gb", 1000000000.0),
    "tb"  => data("tb", 1000000000000.0),
    "pb"  => data("pb", 1e15),
    "kib" => data("kib", 1024.0),
    "mib" => data("mib", 1048576.0),
    "gib" => data("gib", 1073741824.0),
    "tib" => data("tib", 1099511627776.0),
    "pib" => data("pib", 1125899906842624.0),
    "bit" => data("bit", 0.125),
    # Time (base = second)
    "s"   => time("s", 1.0),
    "ms"  => time("ms", 0.001),
    "us"  => time("us", 1e-6),
    "ns"  => time("ns", 1e-9),
    "min" => time("min", 60.0),
    "hr"  => time("hr", 3600.0),
    "day" => time("day", 86400.0),
    "wk"  => time("wk", 604800.0),
    "yr"  => time("yr", 31557600.0),
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
  formatted = result.round(4).to_s.sub(/\.?0+$/, "")
  puts "#{value} #{from.symbol} is #{formatted} #{to.symbol}"
rescue ex
  STDERR.puts "Error: #{ex.message}"
end

def run_repl
  puts "Conv REPL ready."
  loop do
    print "> "
    line = gets || break
    parts = line.strip.split
    unless parts.size == 3
      STDERR.puts "Error: invalid syntax. Expected <value> <from> <to>."
      next
    end
    perform_conversion(parts)
  end
end

list_units = false
repl_mode = false
parser = OptionParser.parse do |par|
  par.banner = "Usage: conv [options] <value> <from_unit> <to_unit>\n\nOptions:"
  par.on("-l", "--list", "List all available units") { list_units = true }
  par.on("-i", "--repl", "Start interactive REPL mode") { repl_mode = true }
  par.on("-h", "--help", "Show this help and exit") { puts par; exit }
end
case
when list_units     then puts Units.list
when repl_mode      then run_repl
when ARGV.size == 3 then perform_conversion(ARGV); exit 0
else                     abort parser
end
