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
    arrays = []
    inport_array = Inport.where(:name => Regexp.new(params[:query_json])).all
    outport_array = Outport.where(:name => Regexp.new(params[:query_json])).all

    query_jsondata_by_inport(arrays,inport_array)

    query_jsondata_by_outport(arrays,outport_array)

    render_arrays =[]
    arrays = arrays.uniq
    arrays.each do |a|
      put_jsondata_into_array(a,render_arrays)
    end
    render :json =>{:result => render_arrays.to_json}
  end

  def query_A_to_B_with_length
    inport_array = []
    render_arrays = get_first_port(inport_array,params[:query_A],params[:query_B],params[:length])
    render_arrays = render_arrays.uniq
    render :json => {:result => render_arrays.to_json}
  end

  def query_A_to_B
    render_arrays = []
    get_all_port_from_A_to_B(render_arrays,params[:query_A],params[:query_B])
    render_arrays = render_arrays.uniq
    render :json => {:result => render_arrays.to_json}
  end

  def query_all_port_before_A
    render_arrays = []
    get_all_port_before_A(render_arrays,params[:query_A])
    render_arrays = render_arrays.uniq
    render :json => {:result => render_arrays.to_json}
  end

  def query_all_port_after_A
    render_arrays = []
    get_all_port_after_A(render_arrays,params[:query_A])
    render_arrays = render_arrays.uniq
    render :json => {:result => render_arrays.to_json}
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

  def opml2graphviz
    
  end

  private
    def put_jsondata_into_array(jsondata,render_arrays)
      hash = {}
      hash[:inPort] = jsondata.inport.name
      hash[:outPort] = jsondata.outport.name
      hash[:desc] = {}
      hash[:desc][:title] = jsondata.desc_title
      hash[:desc][:content] = jsondata.desc_content
      hash[:infoUrl] = {}
      hash[:infoUrl][:title] = jsondata.info_url_title
      hash[:infoUrl][:href] = jsondata.info_url_href
      render_arrays.push(hash)
    end

    def query_jsondata_by_inport(arrays,inport_array)
      inport_array.each do |inport|
        inport_datas = JsonData.where(:inport_id => inport.id).all
        p 444444444444444444
        p inport_datas
        inport_datas.each do |inport_data|
          arrays.push(inport_data)
        end
      end
    end

    def query_jsondata_by_outport(arrays,outport_array)
      outport_array.each do |outport|
        outport_datas = JsonData.where(:outport_id => outport.id).all
        outport_datas.each do |outport_data|
          arrays.push(outport_data)
        end
      end
    end

    def get_all_port_before_A(render_arrays,key_port)
      arrays = []
      outport_array = Outport.where(:name => key_port).all
      query_jsondata_by_outport(arrays,outport_array)

      arrays.each do |a|
        put_jsondata_into_array(a,render_arrays)
        if JsonData.where(:outport => a.inport).all.to_a != nil
          get_all_port_before_A(render_arrays,a.inport)
        end
      end
    end

    def get_all_port_after_A(render_arrays,key_port)
      arrays = []
      inport_array = Inport.where(:name => key_port).all
      p 111111111111111111111111
      p inport_array.first
      query_jsondata_by_inport(arrays,inport_array)

      p 22222222222222
      p arrays.count

      arrays.each do |a|
        p 333333333333333
        p a
        put_jsondata_into_array(a,render_arrays)
        if JsonData.where(:inport => a.outport).all.to_a != nil
          
          get_all_port_after_A(render_arrays,a.outport)
        end
      end
    end

    def get_all_port_from_A_to_B(render_arrays,first_port,last_port)
      arrays = JsonData.where(:inport => first_port).all.to_a
      arrays.each do |a|
        put_jsondata_into_array(a,render_arrays)
        if a.outport != last_port
          if JsonData.where(:inport => a.outport).all.to_a != nil
            get_all_port_from_A_to_B(render_arrays,a.outport,last_port)
          end
        end
      end
    end

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

    def get_next_port(inport_array,outport_array,next_inport,last_port,length)
      obj = {}
      arrays = JsonData.where(:inport => next_inport).all.to_a
      if arrays.length != 0
        arrays.each do |a|
          next_inport_2 = a.outport
          obj[:next_inport_2] = outport_array
          hash = {}
          hash[:inPort] = a.inport
          hash[:outPort] = a.outport
          hash[:desc] = {}
          hash[:desc][:title] = a.desc_title
          hash[:desc][:content] = a.desc_content
          hash[:infoUrl] = {}
          hash[:infoUrl][:title] = a.info_url_title
          hash[:infoUrl][:href] = a.info_url_href
          if arrays = JsonData.where(:inport => next_inport).all.to_a != nil
            if obj[:next_inport_2].length + 1 == length.to_i
              if a.outport == last_port
                obj[:next_inport_2].push(hash)
                array_length = obj[:next_inport_2].length - 1
                (0..array_length).each do |i|
                  inport_array.push(obj[:next_inport_2][i])
                end
              end
            else
              if obj[:next_inport_2].length + 1 < length.to_i
                if a.outport != last_port
                  next_array = []
                  array_length = obj[:next_inport_2].length - 1
                  (0..array_length).each do |i|
                    next_array.push(obj[:next_inport_2][i])
                  end 
                  next_array.push(hash)
                  get_next_port(inport_array,next_array,next_inport_2,last_port,length)
                end
              end
            end
          end
        end
      end
    end

    def get_first_port(inport_array,first_port,last_port,length)
      obj = {}
      arrays = JsonData.where(:inport => first_port).all.to_a
      if arrays.length != 0
        arrays.each do |a|
          next_inport = a.outport
          obj[:next_port] = []
          hash = {}
          hash[:inPort] = a.inport
          hash[:outPort] = a.outport
          hash[:desc] = {}
          hash[:desc][:title] = a.desc_title
          hash[:desc][:content] = a.desc_content
          hash[:infoUrl] = {}
          hash[:infoUrl][:title] = a.info_url_title
          hash[:infoUrl][:href] = a.info_url_href
          if arrays = JsonData.where(:inport => next_inport).all.to_a != nil
            if obj[:next_port].length + 1 == length.to_i
              if a.outport == last_port
                obj[:next_port].push(hash)
                array_length = obj[:next_port].length - 1
                (0..array_length).each do |i|
                  p obj[:next_port][i]
                  inport_array.push(obj[:next_port][i])
                end
              end
            else
              if obj[:next_port].length + 1 < length.to_i
                if a.outport != last_port
                  obj[:next_port].push(hash)
                  get_next_port(inport_array,obj[:next_port],next_inport,last_port,length)
                end
              end
            end
          end
        end
        return inport_array
      end
    end
end