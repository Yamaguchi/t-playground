class CommandsController < ApplicationController

  def index
    @categories = Category.all.sort_by(&:name)
    # @commands = Command.all
  end

  def edit
    @command = Command.find(params[:id])
  end

  def update
    @command = Command.find(params[:id])
    config = { schema: 'http', host: 'localhost', port: 12381, user: 'user', password: 'pass' }
    client = Tapyrus::RPC::TapyrusCoreClient.new(config)

    command_param_hash = if params[:command_params] 
      params[:command_params].to_unsafe_hash
    else
      {}
    end
    command_param_array = command_param_hash.map do |k, v|
      v = v.strip
      next nil if v.empty?
      param = @command.parameters.find_by(index: k.to_i)
      if param.parameter_type == "numeric"
        v.to_i
      elsif param.parameter_type == "string"
        v
      elsif param.parameter_type == "boolean"
        (v == "true" || v == "1") ? true : false
      elsif param.parameter_type == "array"
        JSON.parse(v)
      elsif param.parameter_type == "object"
        JSON.parse(v)
      else
        v
      end
    end
    @result = client.send(@command.name, *command_param_array.compact)
    render :edit
  rescue RuntimeError => e
    # @error = JSON.parse(e.message)
    @error = e.message
    render :edit
  end
end
