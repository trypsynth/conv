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
