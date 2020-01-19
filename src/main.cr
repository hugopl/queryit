require "option_parser"
require "version_from_shard"

require "./app"
require "./detect_database"

VersionFromShard.declare

def parse_options
  uri = nil
  OptionParser.parse! do |parser|
    parser.banner = "Usage: queryit [arguments]"
    parser.on("--uri=URI", "Database server URI, e.g. postgres://localhost/database.") { |db_uri| uri = db_uri }
    parser.on("--version", "Show queryit version and exit.") do
      puts "queryit version #{VERSION}"
      exit
    end
    parser.on("-h", "--help", "Show this help.") do
      puts parser
      exit
    end
  end
  {uri: uri}
end

def main
  options = parse_options
  uri = URI.parse(detect_database(options[:uri]))
  App.new(uri).main_loop
rescue DB::ConnectionRefused
  STDERR.puts "Database connection to #{uri} refused, are you sure this database exists?"
  exit(1)
rescue e : AppError | TextUi::TerminalError | OptionParser::InvalidOption
  STDERR.puts(e.message)
  exit(1)
ensure
  TextUi::Ui.shutdown!
end

main
