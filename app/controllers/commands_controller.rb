class CommandsController < ApplicationController

  def index
    @categories = Category.all.sort_by(&:name)
  end

  def show
    @command = Command.find(params[:id])
    @command_history = CommandHistory.new
  end
end
