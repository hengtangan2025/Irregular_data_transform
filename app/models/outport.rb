class Outport
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  has_many :json_data, :class_name => "JsonData"
end