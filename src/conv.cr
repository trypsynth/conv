require "./conv/units"

module Conv
  def self.perform_conversion(args : Array(String))
    value = args[0].to_f
    from = Units.find(args[1])
    to = Units.find(args[2])
    result = from.convert(value, to: to)
    formatted = result.round(4).to_s.sub(/\.?0+$/, "")
    puts "#{value} #{from.symbol} is #{formatted} #{to.symbol}"
  rescue ex
    STDERR.puts "Error: #{ex.message}"
  end

  def self.run_repl
    puts "Conv REPL - type <value> <from> <to> to convert, or quit/exit/q to exit."
    loop do
      print "> "
      line = gets || break
      parts = line.strip.split
      next if parts.empty?
      break if parts[0].in?("quit", "exit", "q")
      unless parts.size == 3
        STDERR.puts "Error: invalid syntax. Expected <value> <from> <to>."
        next
      end
      perform_conversion(parts)
    end
  end
end
