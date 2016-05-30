require 'tempfile'
require 'open-uri'
require 'net/http'
class IrregularDataTransformsController < ApplicationController
  def index
    
  end

  def transform_lists
    render :layout => false 
  end

  def transfer_page
    # @show_transfer_result = `#{params[:shell_command]}`
  end

  def transfer_action
    require 'fileutils'
    will_transfer_file = params[:transfer_file]
    will_transfer_file_path = File.join("public",will_transfer_file.original_filename)
    FileUtils.cp will_transfer_file.path, will_transfer_file_path
    render :xml => {:strs => `./public/graphml2hintpipe.pl ./public/#{will_transfer_file.original_filename}`}.to_xml
    # redirect_to :action => "transfer_page", :shell_command => "./public/graphml2hintpipe.pl ./public/#{will_transfer_file.original_filename}"
  end

  def graphviz 
  end

  def graphviz_to_gml
  end

  def save_and_query_jsons
  end

  def query_mind_photograph
  end

  def query_json
    render_arrays =[]
    arrays =
    JsonData.where(:outport=>Regexp.new(params[:query_json])).all.to_a+
    JsonData.where(:inport=>Regexp.new(params[:query_json])).all.to_a
    arrays = arrays.uniq
    arrays.each do |a|
      hash = {}
      hash[:inPort] = a.inport
      hash[:outPort] = a.outport
      hash[:desc]={}
      hash[:desc][:title] = a.desc_title
      hash[:desc][:content] = a.desc_content
      hash[:infoUrl]={}
      hash[:infoUrl][:title] = a.info_url_title
      hash[:infoUrl][:href] = a.info_url_href
      render_arrays.push(hash)
    end
    render :json => render_arrays.to_json
    # render :json =>{:result => render_arrays.to_json}
  end

  def graphviz_to_gml_progarm
    dot_file = File.new(File.join("./public","graphviz.dot"), "w+")
    dot_file.puts(params[:graphviz])
    dot_file.close
    `./public/dot2graphml_gml.sh ./public/graphviz.dot ./public/graphviz.gml`
    file = File.read("./public/graphviz.gml")
    render :text => file.encode("UTF-8","gbk")
  end

  # 对话泡泡
  def convert
    pre_path = Rails.root.to_s + "/public/pre.yml"
    chat_text = params[:chat_text].strip
    case params[:chat_type]
    when "QQ"
      @data = conver_qq(chat_text, pre_path)
      render :text => @data.to_yaml
    else
      @data = convert_webchat(chat_text, pre_path)
      render :text => @data.to_yaml
    end

  end

  # 将文件保存到本地
  def save_file_to_local
    fetch_text = params[:save_text]
    file_path = "public/convert_file/convert.yml"
    text_convert = File.new(file_path, 'wb+')
    text_convert.write(fetch_text)
    text_convert.close
  end

  def down_load
    send_file("./public/convert_file/convert.yml",disposition: "attachment", :filename => "convert.yml", type: "application/yml")
  end

  def xml2json
    
  end

  private
    def conver_qq(str, pre_path)
      date1 = /^[\d{2}:\d{2}:\d{2}]{8,}/
      date2 = /^[\d{4}\/\d{1,2}\/\d{1,2} \d{2}:\d{2}:\d{2}]{18,}/

      str = str.gsub(date1, '').gsub(date2, '')

      pattern = /^[\u4E00-\u9FA5\w]+[\s][\d{4}\/\d{1,2}\/\d{1,2} \d{2}:\d{2}:\d{2}]{18,}\s+/
      items = str.scan(pattern)
      values = str.split(pattern).delete_if(&:blank?)

      data = {}
      data['npcs'] = []
      data['scripts'] = []
      items.each_with_index do |item, index|
        if values[index].nil?
          data['scripts'] << ''
          next
        end

        yml_file = YAML::load_file(pre_path)

        yml_file['npcs'][0]['id'] = items[index].gsub(/\d{4}\/\d{1,2}\/\d{1,2} \d{2}:\d{2}:\d{2}/, '').strip
        yml_file['npcs'][0]['name'] = items[index].gsub(/\d{4}\/\d{1,2}\/\d{1,2} \d{2}:\d{2}:\d{2}/, '').strip


        yml_file['scripts'][0]['npc'] = items[index].gsub(/\d{4}\/\d{1,2}\/\d{1,2} \d{2}:\d{2}:\d{2}/, '').strip

        value = values[index].gsub(/\r\n/,'').gsub(/@/, '').gsub(/:/, '').gsub(/\r/, '')
        yml_file['scripts'][0]['sentences'][0]['text'] = value

        
        data['scripts'] << yml_file['scripts'][0]
        data['npcs'] << yml_file['npcs'][0]
      end
      data['npcs'] = data['npcs'].uniq
      data_last = data['npcs'].last
      data_last['direction'] = "right"
      data_last['avatar'] = "http://img.teamkn.com/i/B5VSfH2U.png@100w_100h_1e_1c.png"
      data
    end

    def convert_webchat(str, pre_path)
      str = str.gsub(/\d{2}\:\d{2}/, '').gsub(/\*/, '').gsub(/\n/,'').gsub(/@/, '').gsub(/:/, '').gsub(/\r/, '')
      items = str.scan(/\[(.*?)\]([^\[]*)/)
      data = {}
      data['npcs'] = []
      data['scripts'] = []
      items.each_with_index do |item, index|
        yml_file = YAML::load_file(pre_path)

        yml_file['npcs'][0]['id'] = item[0]
        yml_file['npcs'][0]['name'] = item[0]

        item[1] = item[1].gsub(/^#{item[0]}/, '')
        yml_file['scripts'][0]['npc'] = item[0]
        yml_file['scripts'][0]['sentences'][0]['text'] = item[1]
        data['scripts'] << yml_file['scripts'][0]
        data['npcs'] << yml_file['npcs'][0]
      end
      data['npcs'] = data['npcs'].uniq
      data_last = data['npcs'].last
      data_last['direction'] = "right"
      data_last['avatar'] = "http://img.teamkn.com/i/B5VSfH2U.png@100w_100h_1e_1c.png"
      data
    end
end