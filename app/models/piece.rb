class Piece < ActiveRecord::Base
  belongs_to :player, class_name: "User"
  belongs_to :game

  # override stripping of 'type' field from json
  def as_json(options={})
    super(options.merge({:methods => :type}))
  end
end

