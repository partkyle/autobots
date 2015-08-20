require 'sinatra'
require 'yaml'
require 'json'

schema = YAML.load_file('schema.yml')

before do
  headers['Access-Control-Allow-Origin'] = '*'
end

get '/swagger.json' do
  schema.to_json
end

get '/ping' do
  logger.info env['HTTP_ACCEPT']
  msg = 'PONG'
  case env['HTTP_ACCEPT']
  when 'text/plain'
    msg
  else
    {message: msg}.to_json
  end
end

get '/sayHello' do
  name = params[:name]
  name ||= 'duck duck goose'
  msg = "hello #{name}"
  case env['HTTP_ACCEPT']
  when 'text/plain'
    msg
  else
    {message: msg}.to_json
  end
end

get '/add' do
  a = params[:a]
  b = params[:b]
  res = a.to_i + b.to_i
  case env['HTTP_ACCEPT']
  when 'text/plain'
    res.to_s
  else
    {message: res}.to_json
  end
end
