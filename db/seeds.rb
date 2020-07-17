# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# config = { schema: 'http', host: 'playground.taas.haw.biz', port: 2377, user: 'user', password: 'pass' }
config = { schema: 'http', host: 'localhost', port: 12381, user: 'user', password: 'pass' }
client = Tapyrus::RPC::TapyrusCoreClient.new(config)

help = client.help
lines = help.split("\n")

category = ""
categories = []
commands = []

lines.each do |line|
  next if line.empty?

  if m = /^== (?<category>.*) ==$/.match(line)
    category = m[:category]
    categories << category
  else
    command = line.split(" ")
    commands << { name: command.first, category: category }
  end
end

parameters = {}
commands.each do |command|
  response = client.help(command[:name])
  command[:description] = response

  lines = response.split("\n")
  parameters[command[:name]] = []
  section = :signature

  lines.each do |line|
    if line.empty?
      case section
      when :signature
        section = :summary
      end
      next
    end

    if /^Arguments/.match(line)
      section = :arguments
      next
    elsif /^Result/.match(line)
      section = :result
      next
    elsif /^Examples/.match(line)
      section = :examples
      next
    end

    case section
    when :signature
      command[:signature] = line
    when :summary
      command[:summary] ||= ''
      command[:summary] += line + "\n"
    when :arguments
      if m = /^\d\. *(?<parameter>[\w\"\[\]\(\)]*) *(?<description>.*)$/.match(line)
        parameters[command[:name]] << [m[:parameter], m[:description]]
      end
    when :result
    when :examples
    end
  end
end

categories.each do |category_name|
  Category.create(name: category_name)
end

commands.each do |command|
  record = Command.create(
    name: command[:name], 
    category: Category.find_by(name: command[:category]), 
    description: command[:description],
    summary: command[:summary],
    signature: command[:signature],
  )

  command_parameters = parameters[command[:name]]
  command_parameters.each.with_index do |(parameter, description), index|
    description = description.gsub(/^ */,"").gsub(/ *$/, "")
    parameter = parameter.gsub(/[\"\\]/,"")
    Parameter.create(name: parameter, index: index + 1, description: description, command: record)
  end
end


