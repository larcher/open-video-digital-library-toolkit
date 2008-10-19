module ApplicationHelper

  def tabs_tab_for field
    render :partial => "/shared/tab", :object => field
  end

  def tabs_div_for field
    render :partial => "/shared/div", :object => field
  end

  def file_size file
    case file
    when Asset; file = file.uri
    end
    case file
    when File;
    else file = File.new( File.join( Asset::ASSET_DIR,
                                      file[8,file.length] ) )

    end
    number_to_human_size(file.stat.size) if File.file?(file)
  end
  
  def sq_path sq
    if sq.descriptor_value
      if !sq.query_string.blank?
        descriptor_value_videos_path( sq.descriptor_value, :query => sq.query_string )
      else
        descriptor_value_videos_path( sq.descriptor_value )
      end
    else
      if !sq.query_string.blank?
        videos_path( :query => sq.query_string )
      else
        videos_path
      end
    end
  end

  def browse_descriptors_and_types video
    descriptors = video.descriptors
    types = ( descriptors.map { |d| d.descriptor_type } ).uniq
    types = DescriptorType.browse.select { |dt| types.include? dt }
    types.map { |t| [ t, descriptors.select { |d| d.descriptor_type == t } ] }
  end

  def int_to_duration v
    return nil if v.nil?
    h = v/3600
    m = ( v % 3600 ) / 60
    s = ( v % 3600 ) % 60
    "%02d:%02d:%02d" % [ h, m, s ]
  end

  def partial
    params[:action].singularize
  end
  
  def mailto collection
    by = User.find_by_id(collection.user_id).login
    subject = url_encode( h( "Playlist entitled #{collection.title} by #{by}" ))
    body = url_encode(h( <<EOS ))
Playlist link: #{collection_url(collection)}
Link to #{Library.title}: #{root_url}
EOS
    "mailto:?subject=#{subject}&amp;body=#{body}"
  end

  def mail_video video
    subject = url_encode( h( "Video entitled #{video.title}" ) )
    body = url_encode( h( <<EOS ) )
Video: #{video_url(video)}
#{Library.title}: #{root_url}
EOS
    "mailto:?subject=#{subject}&amp;body=#{body}"
  end

  def bookmark_options( video )
    options = current_user.collections.map do |c|
      disabled = ""
      if c.video_ids.include? video.id
        disabled = ' disabled="disabled"'
      end
      "<option value=\"#{c.id}\"#{disabled}>#{h c.title}</option>"
    end
    
    options.join("")
  end

  def container_text collection
    collection.user_id == Library.collections_user_id ? "collection" \
                                                       : "playlist"
  end

  def containers_text collection
    container_text( collection ).pluralize
  end

  def owner_text collection
    owner = nil
    if current_user and current_user.id == collection.user_id
      owner = "my"
    elsif collection.user_id != Library.collections_user_id
      owner = collection.user.login
    end
    owner
  end

  def type_id object
    if object
      id = object.id
      if id.nil?
        "new_" + object.object_id.to_s
      else
        id.to_s
      end
    else
      raise ArgumentError
    end
  end

  def error_class object
    object.errors.empty? ? {} : { :class => "error" }
  end


end
