class CommandHistoriesController < ApplicationController
  def create
    @command = Command.find(params[:id])
    values = if params[:command_params] 
      params[:command_params].to_unsafe_hash
    else
      {}
    end

    # config = { schema: 'http', host: 'localhost', port: 12381, user: 'user', password: 'pass' }
    config = { schema: 'http', host: 'playground.taas.haw.biz', port: 2377, user: 'user', password: 'pass' }
    client = Tapyrus::RPC::TapyrusCoreClient.new(config)

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
