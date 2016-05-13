require 'tempfile'
require 'open-uri'
require 'net/http'
class IrregularDataTransformsController < ApplicationController
  def index
    
  end

  def transfer_page
    @show_transfer_result = `#{params[:shell_command]}`
  end

  def transfer_action
    require 'fileutils'
    will_transfer_file = params[:transfer_file]
    will_transfer_file_path = File.join("public",will_transfer_file.original_filename)
    FileUtils.cp will_transfer_file.path, will_transfer_file_path
    redirect_to :action => "transfer_page", :shell_command => "./public/graphml2hintpipe.pl ./public/#{will_transfer_file.original_filename}"
  end

  def graphviz 
  end

  def graphviz_to_gml
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
    @data = conver_qq(chat_text, pre_path)
    render :text => @data.to_yaml
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

  private
    def conver_qq(str, pre_path)
      date1 = /^[\d{2}:\d{2}:\d{2}]{8,}/
      date2 = /^[\d{4}\/\d{1,2}\/\d{1,2} \d{2}:\d{2}:\d{2}]{18,}/

      str = str.gsub(date1, '').gsub(date2, '')

      pattern = /^[\u4E00-\u9FA5\w]+[\s][\d{4}\/\d{1,2}\/\d{1,2} \d{2}:\d{2}:\d{2}]{18,}\s+/
      items = str.scan(pattern)
      values = str.split(pattern).delete_if(&:blank?)

      data = {}
      data['scripts'] = []
      items.each_with_index do |item, index|
        if values[index].nil?
          data['scripts'] << ''
          next
        end

        yml_file = YAML::load_file(pre_path)

        yml_file['scripts'][0]['npc'] = items[index].gsub(/\d{4}\/\d{1,2}\/\d{1,2} \d{2}:\d{2}:\d{2}/, '').strip

        value = values[index].gsub(/\r\n/,'').gsub(/@/, '').gsub(/:/, '').gsub(/\r/, '')
        yml_file['scripts'][0]['sentences'][0]['text'] = value

        data['scripts'] << yml_file['scripts'][0]
      end
      data
    end

end