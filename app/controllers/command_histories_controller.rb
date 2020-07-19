class CommandHistoriesController < ApplicationController
  def create
    @command = Command.find(params[:id])
    values = if params[:command_params] 
      params[:command_params].to_unsafe_hash
    else
      {}
    end

    yaml = Pathname.new(Rails.root.join('config', 'tapyrus.yml')) 
    config = YAML.load(ERB.new(yaml.read).result).deep_symbolize_keys
    client = Tapyrus::RPC::TapyrusCoreClient.new(config[Rails.env.to_sym])

    command_param_array = values.map do |k, v|
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
    redirect_to @command, flash: { result: @result, values: values }
  rescue RuntimeError => e
    # @error = JSON.parse(e.message)
    @error = e.message
    redirect_to @command, flash: { error: @error[0..1000], values: values }
  end
end
