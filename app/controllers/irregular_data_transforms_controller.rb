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

  # 对话泡泡
  def convert
    pre_path = Rails.root.to_s + "/public/pre.yml"
    
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