require 'json'

config = JSON.parse(STDIN.read)

if config["env_vars"].is_a?(Hash)
  config["env_vars"].each do |k,v|
    puts "export #{k}=\"#{v}\""
  end
end
