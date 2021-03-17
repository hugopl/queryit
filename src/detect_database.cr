require "yaml"
require "./app_error"

def detect_rails_database
  config = YAML.parse(File.read("./config/database.yml"))
  env = "development"
  hostname = config.dig?(env, "hostname") || "localhost"
  username = config.dig?(env, "username") || ""
  database = config.dig(env, "database")
  adapter = config.dig(env, "adapter")

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

def detect_database(uri)
  uri ||= detect_rails_database
  uri ||= detect_amber_database
  raise AppError.new("Could not find rails or amber database configuration.") if uri.nil?

  uri.gsub(/^postgresql/, "postgres")
end
