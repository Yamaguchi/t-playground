class CommandHistory
  include ActiveModel::Model

  attr_writer :parameters

  def initialize
    @parameters = {}
  end

  def parameter_at(index)
    @parameters[index]
  end
end
