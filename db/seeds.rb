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
    command_name = line.split(" ").first
    commands << [command_name, category]
  end
end

parameters = {}
description = {}
commands.each do |(command_name, category)|
  help = client.help(command_name)
  description[command_name] = help
  lines = help.split("\n")
  parameters[command_name] = []
  section = nil

  lines.each do |line|
    next if line.empty?

    if /^Arguments/.match(line)
      section = :arguments
    elsif /^Result/.match(line)
      section = :result
    end

    if section == :arguments
      if m = /^\d\. *(?<parameter>[\w\"\[\]\(\)]*) *(?<description>.*)$/.match(line)
        parameters[command_name] << [m[:parameter], m[:description]]
      end
    end
  end
end

categories.each do |category_name|
  Category.create(name: category_name)
end

commands.each do |(command_name, category)|
  command = Command.create(
    name: command_name, 
    category: Category.find_by(name: category), 
    description: description[command_name]
  )

  command_parameters = parameters[command_name]
  command_parameters.each.with_index do |(parameter, description), index|
    description = description.gsub(/^ */,"").gsub(/ *$/, "")
    parameter = parameter.gsub(/[\"\\]/,"")
    Parameter.create(name: parameter, index: index + 1, description: description, command: command)
  end
  pp Parameter.all
end


