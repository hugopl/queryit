require "option_parser"
require "yaml"
require "version_from_shard"

require "./app"

VersionFromShard.declare

def detect_rails_database
  config = YAML.parse(File.read("./config/database.yml"))
  env = "development"
  hostname = config.dig?(env, "hostname") || "localhost"
  database = config.dig(env, "database")
  adapter = config.dig(env, "adapter")

  "#{adapter}://#{hostname}/#{database}"
rescue e : Errno
  nil
end

def detect_amber_database
  config = YAML.parse(File.read("./config/environments/development.yml"))
  config["database_url"].to_s
rescue
  nil
end

def parse_options
  uri = ""
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

def detect_database(uri)
  uri ||= detect_rails_database
  uri ||= detect_amber_database
  raise AppError.new("Could not find rails or amber database configuration.") if uri.nil?

  uri.gsub(/^postgresql/, "postgres")
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

main if PROGRAM_NAME == __FILE__
