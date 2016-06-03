class JsonDatasController < ApplicationController
  def index
    @json_datas = JsonData.all
  end

  def new
    @json_data = JsonData.new
  end

  def enter_data
    data = JsonData.create(
        # :inport=> params[:json_data][:inport],
        # :outport=> params[:json_data][:outport],
        :desc_title=> "内容概要",
        :desc_content=> params[:json_data][:desc_content],
        :info_url_title=> "参考链接",
        :info_url_href=> params[:json_data][:info_url_href])
    data.inport = params[:json_data][:inport]
    data.outport = params[:json_data][:outport]
    if data.save
      if request.xhr? == 0
        render :text => "保存成功"
      else
        redirect_to "/json_datas/new",:notice=>'保存成功'
      end
    else
      redirect_to "/json_datas/new",:notice=>data.errors
    end
  end

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
        :info_url_href=>json_data["infoUrl"]["href"],
        :tags=>json_data["tags"])
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

  def query_json
    @json_datas = JsonData.where(:outport=>Regexp.new(params[:query_json])).all.to_a + JsonData.where(:inport=>Regexp.new(params[:query_json])).all.to_a
  end

  def edit
    @json_data = JsonData.find(params[:id])
  end

  def update
    json_data = JsonData.find(params[:id])
    data = json_data.update(
        # :inport=> params[:json_data][:inport],
        # :outport=> params[:json_data][:outport],
        :desc_title=> "内容概要",
        :desc_content=> params[:json_data][:desc_content],
        :info_url_title=> "参考链接",
        :info_url_href=> params[:json_data][:info_url_href])
    data.inport = params[:json_data][:inport]
    data.outport = params[:json_data][:outport]

    if json_data.save
      if request.xhr? == 0
        render :text => "修改成功"
      else
        redirect_to "/json_datas",:notice=>'保存成功'
      end
    else
      redirect_to "/json_datas/#{params[:id]}/new",:notice=>data.errors
    end
  end

  def destroy
    json_data = JsonData.find(params[:id])
    json_data.destroy
    redirect_to "/json_datas"
  end

  def page_create 
  end
end