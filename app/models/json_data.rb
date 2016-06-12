class JsonData
  include Mongoid::Document
  include Mongoid::Timestamps
  # field :inport, :type => String
  # field :outport, :type => String
  field :desc_title, :type => String
  field :desc_content, :type => String
  field :info_url_title, :type => String
  field :info_url_href, :type => String
  field :tags, :type => String
  # validates :inport, :presence => true
  # validates :outport, :presence => true
  before_create :replace_repeated_data
  belongs_to :inport, :class_name => "Inport"
  belongs_to :outport, :class_name => "Outport"


  def replace_repeated_data
    if JsonData.where(inport:self.inport,outport:self.outport).exists?
      JsonData.where(inport:self.inport,outport:self.outport).delete
    end
  end

end