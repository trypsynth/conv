require "spec"
require "../src/conv"

describe Conv::Unit do
  describe "#convert" do
    it "raises IncompatibleUnitError for different kinds" do
      meter = Conv::Units.find("m")
      gram = Conv::Units.find("g")
      expect_raises(Conv::IncompatibleUnitError) { meter.convert(1.0, to: gram) }
    end

    it "returns identity for same unit" do
      meter = Conv::Units.find("m")
      meter.convert(42.0, to: meter).should eq(42.0)
    end
  end
end

describe Conv::Units do
  describe ".find" do
    it "finds units case-insensitively" do
      Conv::Units.find("KG").symbol.should eq("kg")
      Conv::Units.find("Km").symbol.should eq("km")
    end

    it "raises InvalidUnitError for unknown units" do
      expect_raises(Conv::InvalidUnitError) { Conv::Units.find("xyz") }
    end
  end

  describe ".list" do
    it "includes all unit kinds" do
      output = Conv::Units.list
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
    c = Conv::Units.find("c")
    f = Conv::Units.find("f")
    c.convert(0.0, to: f).should be_close(32.0, 0.001)
    c.convert(100.0, to: f).should be_close(212.0, 0.001)
    c.convert(-40.0, to: f).should be_close(-40.0, 0.001)
  end

  it "converts F to C" do
    f = Conv::Units.find("f")
    c = Conv::Units.find("c")
    f.convert(32.0, to: c).should be_close(0.0, 0.001)
    f.convert(212.0, to: c).should be_close(100.0, 0.001)
  end

  it "converts C to K" do
    c = Conv::Units.find("c")
    k = Conv::Units.find("k")
    c.convert(0.0, to: k).should be_close(273.15, 0.001)
    c.convert(-273.15, to: k).should be_close(0.0, 0.001)
  end

  it "converts K to R" do
    k = Conv::Units.find("k")
    r = Conv::Units.find("r")
    k.convert(0.0, to: r).should be_close(0.0, 0.001)
    k.convert(100.0, to: r).should be_close(180.0, 0.001)
  end

  it "converts C to De" do
    c = Conv::Units.find("c")
    de = Conv::Units.find("de")
    c.convert(100.0, to: de).should be_close(0.0, 0.001)
    c.convert(0.0, to: de).should be_close(150.0, 0.001)
  end
end

describe "Length conversions" do
  it "converts km to m" do
    km = Conv::Units.find("km")
    m = Conv::Units.find("m")
    km.convert(1.0, to: m).should be_close(1000.0, 0.001)
  end

  it "converts miles to km" do
    mi = Conv::Units.find("mi")
    km = Conv::Units.find("km")
    mi.convert(1.0, to: km).should be_close(1.609344, 0.001)
  end

  it "converts inches to cm" do
    inch = Conv::Units.find("in")
    cm = Conv::Units.find("cm")
    inch.convert(1.0, to: cm).should be_close(2.54, 0.001)
  end

  it "converts feet to meters" do
    ft = Conv::Units.find("ft")
    m = Conv::Units.find("m")
    ft.convert(1.0, to: m).should be_close(0.3048, 0.001)
  end
end

describe "Weight conversions" do
  it "converts kg to lb" do
    kg = Conv::Units.find("kg")
    lb = Conv::Units.find("lb")
    kg.convert(1.0, to: lb).should be_close(2.2046, 0.01)
  end

  it "converts oz to g" do
    oz = Conv::Units.find("oz")
    g = Conv::Units.find("g")
    oz.convert(1.0, to: g).should be_close(28.3495, 0.001)
  end

  it "converts t to kg" do
    t = Conv::Units.find("t")
    kg = Conv::Units.find("kg")
    t.convert(1.0, to: kg).should be_close(1000.0, 0.001)
  end
end

describe "Volume conversions" do
  it "converts gal to l" do
    gal = Conv::Units.find("gal")
    l = Conv::Units.find("l")
    gal.convert(1.0, to: l).should be_close(3.78541, 0.001)
  end

  it "converts cups to ml" do
    cup = Conv::Units.find("cup")
    ml = Conv::Units.find("ml")
    cup.convert(1.0, to: ml).should be_close(236.588, 0.1)
  end
end

describe "Data conversions" do
  it "converts kb to b" do
    kb = Conv::Units.find("kb")
    b = Conv::Units.find("b")
    kb.convert(1.0, to: b).should be_close(1000.0, 0.001)
  end

  it "converts kib to b" do
    kib = Conv::Units.find("kib")
    b = Conv::Units.find("b")
    kib.convert(1.0, to: b).should be_close(1024.0, 0.001)
  end

  it "distinguishes decimal and binary units" do
    gb = Conv::Units.find("gb")
    gib = Conv::Units.find("gib")
    b = Conv::Units.find("b")
    decimal = gb.convert(1.0, to: b)
    binary = gib.convert(1.0, to: b)
    decimal.should be_close(1_000_000_000.0, 1.0)
    binary.should be_close(1_073_741_824.0, 1.0)
  end

  it "converts bits to bytes" do
    bit = Conv::Units.find("bit")
    b = Conv::Units.find("b")
    bit.convert(8.0, to: b).should be_close(1.0, 0.001)
  end
end

describe "Time conversions" do
  it "converts hours to seconds" do
    hr = Conv::Units.find("hr")
    s = Conv::Units.find("s")
    hr.convert(1.0, to: s).should be_close(3600.0, 0.001)
  end

  it "converts days to hours" do
    day = Conv::Units.find("day")
    hr = Conv::Units.find("hr")
    day.convert(1.0, to: hr).should be_close(24.0, 0.001)
  end

  it "converts weeks to days" do
    wk = Conv::Units.find("wk")
    day = Conv::Units.find("day")
    wk.convert(1.0, to: day).should be_close(7.0, 0.001)
  end
end
