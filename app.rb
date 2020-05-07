require 'dotenv/load'
require 'sinatra'

require './todoist'

before do
  content_type :json
  body = request.body.read

  @body = JSON.parse body if !body.empty?
end

def render_json json
  response.body = JSON.dump(json)
end

get '/todoist/:templateId' do
  templateId = params["templateId"]

  Todoist.new(templateId).run()
  render_json({status: 200})
end

post '/' do
  render_json(@body)
end