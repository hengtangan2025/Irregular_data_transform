class JsonData
  include Mongoid::Document
  include Mongoid::Timestamps
  field :inport, :type => String
  field :outport, :type => String
  field :desc_title, :type => String
  field :desc_content, :type => String
  field :info_url_title, :type => String
  field :info_url_href, :type => String
  validates :inport, :presence => true
  validates :outport, :presence => true

end