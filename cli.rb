require 'yaml'
require 'json'
require 'rest-client'

require 'optparse'

root_uri = 'http://localhost:4567'
swagger_uri = "#{root_uri}/swagger.json"
bot_tag = 'bot'

resp = RestClient.get(swagger_uri)
swagger = JSON.load(resp.body)

ops = []

swagger['paths'].each do |path, methods|
  methods.each do |method, definition|
    if definition['tags'] and definition['tags'].include?(bot_tag)
      ops << {
        operationId: definition['operationId'],
        method: method,
        path: path,
        parameters: definition['parameters']
      }
    end
  end
end


global = OptionParser.new do |opts|
  opts.banner = "Usage: opt.rb [options] [subcommand [options]]"
end

help = false

suboptions = {}

subcommands = {}
ops.each do |op|
  subcommands[op[:operationId]] = OptionParser.new do |opts|
    opts.on('--help') do
      help = true
    end
    if op[:parameters]
      suboptions[op[:operationId]] = {}
      op[:parameters].each do |param|
        opts.on("--#{param['name']} [asdf]", String) do |v|
          suboptions[op[:operationId]][param['name']] = v
        end
      end
    end
  end
end

global.order!
command = ARGV.shift

if subcommands[command]
  options = subcommands[command].order!

  action = nil

  ops.each do |op|
    if command == op[:operationId]
      action = op
    end
  end

  if help
    puts action
  else
    params = suboptions[command]
    puts RestClient.send(action[:method], "#{root_uri}#{action[:path]}", :params => params, 'Accept' => 'text/plain')
  end
end
