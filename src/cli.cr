require "./conv"

list_units = false
repl_mode = false
parser = OptionParser.parse do |par|
  par.banner = "Usage: conv [options] <value> <from_unit> <to_unit>\n\nOptions:"
  par.on("-l", "--list", "List all available units") { list_units = true }
  par.on("-i", "--repl", "Start interactive REPL mode") { repl_mode = true }
  par.on("-h", "--help", "Show this help and exit") { puts par; exit }
  par.invalid_option do |flag|
    STDERR.puts "Unknown option: #{flag}"
    STDERR.puts par
    exit 1
  end
end
case
when list_units     then puts Units.list
when repl_mode      then run_repl
when ARGV.size == 3 then perform_conversion(ARGV)
when ARGV.empty?    then run_repl
else                     abort parser
end
