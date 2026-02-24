require "spec"
require "../src/conv"

describe Unit do
  describe "#convert" do
    it "raises IncompatibleUnitError for different kinds" do
      meter = Units.find("m")
      gram = Units.find("g")
      expect_raises(IncompatibleUnitError) { meter.convert(1.0, to: gram) }
    end

    it "returns identity for same unit" do
      meter = Units.find("m")
      meter.convert(42.0, to: meter).should eq(42.0)
    end
  end
end

describe Units do
  describe ".find" do
    it "finds units case-insensitively" do
      Units.find("KG").symbol.should eq("kg")
      Units.find("Km").symbol.should eq("km")
    end

    it "raises InvalidUnitError for unknown units" do
      expect_raises(InvalidUnitError) { Units.find("xyz") }
    end
  end

  describe ".list" do
    it "includes all unit kinds" do
      output = Units.list
      output.should contain("Temperature")
      output.should contain("Length")
      output.should contain("Weight")
      output.should contain("Volume")
      output.should contain("Data")
      output.should contain("Time")
    end
  end
end

describe "Temperature conversions" do
  it "converts C to F" do
    c = Units.find("c")
    f = Units.find("f")
    c.convert(0.0, to: f).should be_close(32.0, 0.001)
    c.convert(100.0, to: f).should be_close(212.0, 0.001)
    c.convert(-40.0, to: f).should be_close(-40.0, 0.001)
  end

  it "converts F to C" do
    f = Units.find("f")
    c = Units.find("c")
    f.convert(32.0, to: c).should be_close(0.0, 0.001)
    f.convert(212.0, to: c).should be_close(100.0, 0.001)
  end

  it "converts C to K" do
    c = Units.find("c")
    k = Units.find("k")
    c.convert(0.0, to: k).should be_close(273.15, 0.001)
    c.convert(-273.15, to: k).should be_close(0.0, 0.001)
  end

  it "converts K to R" do
    k = Units.find("k")
    r = Units.find("r")
    k.convert(0.0, to: r).should be_close(0.0, 0.001)
    k.convert(100.0, to: r).should be_close(180.0, 0.001)
  end

  it "converts C to De" do
    c = Units.find("c")
    de = Units.find("de")
    c.convert(100.0, to: de).should be_close(0.0, 0.001)
    c.convert(0.0, to: de).should be_close(150.0, 0.001)
  end
end

describe "Length conversions" do
  it "converts km to m" do
    km = Units.find("km")
    m = Units.find("m")
    km.convert(1.0, to: m).should be_close(1000.0, 0.001)
  end

  it "converts miles to km" do
    mi = Units.find("mi")
    km = Units.find("km")
    mi.convert(1.0, to: km).should be_close(1.609344, 0.001)
  end

  it "converts inches to cm" do
    inch = Units.find("in")
    cm = Units.find("cm")
    inch.convert(1.0, to: cm).should be_close(2.54, 0.001)
  end

  it "converts feet to meters" do
    ft = Units.find("ft")
    m = Units.find("m")
    ft.convert(1.0, to: m).should be_close(0.3048, 0.001)
  end
end

describe "Weight conversions" do
  it "converts kg to lb" do
    kg = Units.find("kg")
    lb = Units.find("lb")
    kg.convert(1.0, to: lb).should be_close(2.2046, 0.01)
  end

  it "converts oz to g" do
    oz = Units.find("oz")
    g = Units.find("g")
    oz.convert(1.0, to: g).should be_close(28.3495, 0.001)
  end

  it "converts t to kg" do
    t = Units.find("t")
    kg = Units.find("kg")
    t.convert(1.0, to: kg).should be_close(1000.0, 0.001)
  end
end

describe "Volume conversions" do
  it "converts gal to l" do
    gal = Units.find("gal")
    l = Units.find("l")
    gal.convert(1.0, to: l).should be_close(3.78541, 0.001)
  end

  it "converts cups to ml" do
    cup = Units.find("cup")
    ml = Units.find("ml")
    cup.convert(1.0, to: ml).should be_close(236.588, 0.1)
  end
end

describe "Data conversions" do
  it "converts kb to b" do
    kb = Units.find("kb")
    b = Units.find("b")
    kb.convert(1.0, to: b).should be_close(1000.0, 0.001)
  end

  it "converts kib to b" do
    kib = Units.find("kib")
    b = Units.find("b")
    kib.convert(1.0, to: b).should be_close(1024.0, 0.001)
  end

  it "distinguishes decimal and binary units" do
    gb = Units.find("gb")
    gib = Units.find("gib")
    b = Units.find("b")
    decimal = gb.convert(1.0, to: b)
    binary = gib.convert(1.0, to: b)
    decimal.should be_close(1_000_000_000.0, 1.0)
    binary.should be_close(1_073_741_824.0, 1.0)
  end

  it "converts bits to bytes" do
    bit = Units.find("bit")
    b = Units.find("b")
    bit.convert(8.0, to: b).should be_close(1.0, 0.001)
  end
end

describe "Time conversions" do
  it "converts hours to seconds" do
    hr = Units.find("hr")
    s = Units.find("s")
    hr.convert(1.0, to: s).should be_close(3600.0, 0.001)
  end

  it "converts days to hours" do
    day = Units.find("day")
    hr = Units.find("hr")
    day.convert(1.0, to: hr).should be_close(24.0, 0.001)
  end

  it "converts weeks to days" do
    wk = Units.find("wk")
    day = Units.find("day")
    wk.convert(1.0, to: day).should be_close(7.0, 0.001)
  end
end
