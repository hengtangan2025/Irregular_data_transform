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
    render :json =>{:result => render_arrays.to_json}
  end

  def graphviz_to_gml_progarm
    dot_file = File.new(File.join("./public","graphviz.dot"), "w+")
    dot_file.puts(params[:graphviz])
    dot_file.close
    `./public/dot2graphml_gml.sh ./public/graphviz.dot ./public/graphviz.gml`
    file = File.read("./public/graphviz.gml")
    render :text => file.encode("UTF-8","gbk")
  end

  def xml2json
    
  end

end