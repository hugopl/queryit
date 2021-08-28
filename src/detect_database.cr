require "levenshtein"
require "yaml"

require "./app_error"

SUPPORTED_DRIVERS = %w(postgres sqlite mysql)

def detect_rails_database
  config = YAML.parse(File.read("./config/database.yml"))
  env = "development"
  hostname = config.dig?(env, "hostname") || "localhost"
  username = config.dig?(env, "username") || ""
  database = config.dig(env, "database")
  rails_adapter = config.dig(env, "adapter").as_s
  adapter = Levenshtein.find(rails_adapter, SUPPORTED_DRIVERS, 4)
  raise AppError.new("Unsupported database adapter: #{rails_adapter}.") if adapter.nil?

  username = "#{username}@" if username
  "#{adapter}://#{username}#{hostname}/#{database}"
rescue File::Error
  nil
end

def detect_amber_database
  config = YAML.parse(File.read("./config/environments/development.yml"))
  config["database_url"].to_s
rescue File::Error
  nil
end

def detect_database : URI
  uri = detect_rails_database
  uri ||= detect_amber_database
  raise AppError.new("Could not find rails or amber database configuration.") if uri.nil?

  URI.parse(uri)
end
