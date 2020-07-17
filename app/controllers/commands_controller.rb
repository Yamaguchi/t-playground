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

    command_params = params[:command_params] || {}
    p command_params.values.map{ |v| v.empty? ? nil: v }.compact
    @result = client.send(@command.name, *command_params.values.map{ |v| v.empty? ? nil: v }.compact)
    render :edit
  rescue RuntimeError => e
    @error = JSON.parse(e.message)
    render :edit
  end
end
