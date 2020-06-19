require 'net/http'
require 'uuid'

class Todoist
  def initialize(templateId)
    @templates = JSON.parse(File.read('./templates.json'))
    @key = ENV["TODOIST_KEY"] 
    @projects = projects
    @templateId = templateId.to_i
  end

  def run
    template = @templates.find { |t| t["id"] == @templateId }

    task = template["task"]
    subtasks = template["subtasks"]
    projectName = template["projectName"]
    due = template["due"]

    project = project_by_name(projectName)
    todoistTask = create_task(task["name"], project["id"], due)
    parentId = todoistTask["temp_id_mapping"].keys[0]

    subtasks.each do |subtask|
      create_task subtask["name"], project["id"], nil, parentId
    end
  end

  def create_task name, projectId, due, parentId = nil
    dueObject = {
      "string": due
    };
  
    commands = [
      {
        type: 'item_add',
        temp_id: uuid,
        uuid: uuid,
        args: {
          priority: 4,
          content: name,
          project_id: projectId,
          parent_id: parentId,
          due: (due ? dueObject : {}),
        }
      }
    ]

    stringCommands = JSON.unparse(commands)
    url = build_url("&commands=#{stringCommands}");
  
    get(url)
  end

  private

  def projects 
    url = build_url("&sync_token=*&resource_types=[\"projects\"]");
    response = get url;
    response["projects"]
  end

  def project_by_name name
    @projects.find { |p| p["name"] == name }
  end

  def build_url path
    "https://api.todoist.com/sync/v8/sync?token=#{@key}#{path}";
  end

  def get url
    uri = URI(url)
    JSON.parse(Net::HTTP.get(uri))
  end

  def uuid
    UUID.new.generate
  end
end