class JsonDatasController < ApplicationController

  def create
    json_datas = JSON.parse(params[:save_json])
    ary =[]
    json_datas.each_with_index do |json_data,index|
      data = JsonData.new(
        :inport=>json_data["inPort"],
        :outport=>json_data["outPort"],
        :desc_title=>json_data["desc"]["title"],
        :desc_content=>json_data["desc"]["content"],
        :info_url_title=>json_data["infoUrl"]["title"],
        :info_url_href=>json_data["infoUrl"]["href"])
      if data.save
        ary[index]=data.id
      end
    end
    if ary.include?(nil)
      # del
      render :text => "保存失败"
    else
      render :text => "全部保存成功"
    end
  end

  def new
  end

  def page_create 
  end
end