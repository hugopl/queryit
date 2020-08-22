require "yaml"

class Config
  include YAML::Serializable

  property last_query : Hash(String, String)?

  def initialize
  end

  def last_query : Hash(String, String)
    @last_query ||= Hash(String, String).new
  end
end
