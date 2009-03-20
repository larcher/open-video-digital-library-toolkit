require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VideosController do

  describe "#recent" do

    before(:each) do
      get :recent
    end
    
    it "should assign @videos" do
      assigns[:videos].should_not be_nil
      # this works whether we are an array or a WillPaginate::Collection
      ( Array === assigns[:videos] ).should be_true
    end
    
  end

  describe "#index" do

    before(:each) do
      get :index
    end
    
    it "should return a successful response" do
      response.should be_success
    end

    it "should set current from property_type if given" do
      type = PropertyType.find :first
      get :index, :property_type_id => type.id
      pending "decision on whether/how to keep display this"
      assigns[:current].should == type
    end

    it "should set current from descriptor if given" do
      d = DescriptorValue.find :first
      d.should_not be_nil
      get :index, :descriptor_value_id => d.id
      pending "decision on whether/how to keep display this"
      assigns[:current].should == d
    end

    it "should filter videos by property if given" do
      d = DescriptorValue.find :first
      d.should_not be_nil
      pending "decision on whether/how to keep display this"
      get :index, :descriptor_value_id => d.id
      assigns[:videos].size.should > 0
      assigns[:videos].size.should < Video.count
    end

  end
  
  describe "#new, when the filename parameter is a valid filename with no directory information" do
    before(:each) do
      login_as_admin
      @filename = "a_great_video.mov"
      get :new, :filename => @filename
    end
    
    it "should return a successful response" do
      response.should be_success
    end
    
    it "should assign @video to a new instance of Video with its filename prepopulated from the params" do
      pending "rework with new asset stuff"
      assigns[:video].should_not be_nil
      assigns[:video].should be_an_instance_of(Video)
      assigns[:video].should be_new_record
      assigns[:video].assets[0].uri.should == "file:///" + @filename
    end
  end
  
  describe "#new, when the filename parameter refers to a file outside the videos directory" do    
    it "should return a 404" do
      pending "rework with new asset stuff"
      login_as_admin
      get :new, :filename => '../README.md'
      response.should be_missing
    end
  end
  
  # describe "#new, when the filename parameter is invalid, eg: %0C"
  
  describe "#create with valid params" do
    before(:all) do
      @file = create_temp_asset("cute_with_chris.fla")
    end
    
    after(:all) do
      File.unlink @file.path
    end

    before(:each) do
      login_as_admin
    end

    def do_post
      post :create, :video => {:filename => "cute_with_chris.fla", :title => "teen cult machine", :sentence => "all your dreams are dead"}
    end
    
    it "should make a new video" do
      pending "this has been reworked to a tab form"
      lambda { do_post }.should change(Video, :count).by(1)
    end
    
    it "should redirect to the videos index" do
      pending "this has been reworked to a tab form"
      do_post
      response.should be_redirect
      response.should redirect_to(videos_path)
    end
    
    it "should set the flash" do
      pending "this has been reworked to a tab form"
      do_post
      flash[:notice].should_not be_blank
    end
  end
  
  describe "#create when the file does not exist" do
    before(:each) do
      # note, no before(:all) this time
      login_as_admin
      pending "filename is not used anymore"
      post :create, :video => {:filename => "this file is not there", :title => "teen cult machine", :sentence => "all your dreams are dead"}
    end
    
    it "should not cause a 500 server error response" do
      response.should_not be_error
    end
    
    it "should display the new page with the fields populated and with errors" do
      pending "this has been reworked to a tab form"
      response.should be_success
      response.body.should == "videos/form"
      assigns[:video].errors.should_not be_empty
    end
  end
  
  describe "#create with invalid params" do
    before(:all) do
      @file = create_temp_asset("cute_with_chris.fla")
    end
    
    after(:all) do
      File.unlink @file.path
    end

    def do_post
      login_as_admin
      pending "filename is not used anymore"
      post :create, :video => {:filename => "cute_with_chris.fla", :title => "", :sentence => "all your dreams are dead"}
    end
    
    it "should not make a new video" do
      lambda { do_post }.should_not change(Video, :count)
    end
    
    it "should display the new page with the fields populated and with errors" do
      pending "this has been reworked to a tab form"
      do_post
      response.should be_success
      response.body.should == "videos/form"
      assigns[:video].errors.should_not be_empty
    end
  end
  
  describe "#edit" do

    before(:each) do
      login_as_admin
      @video = Factory(:video)
      get :edit, :id => @video.id
    end
    
    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should assign @video with the video" do
      assigns[:video].should == @video
    end
    
    it "should render the form" do
      pending "this has been reworked to a tab form"
      response.body.should == "videos/form"
    end
  end
  
  describe "#update with valid params" do
    before(:each) do
      login_as_admin
      @video = Factory(:video)
      put :update, :id => @video.id, :video => {:title => "new title"}
    end
    
    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should should be a redirect to the index" do
      response.should redirect_to(video_path(@video.id))
    end
    
    it "should update the video" do
      @video.reload
      @video.title.should == "new title"
    end
    
    it "should set the flash" do
      flash[:notice].should_not be_blank
    end
  end
  
  describe "#update with invalid params" do
    before(:each) do
      login_as_admin
      @video = Factory(:video)
      put :update, :id => @video.id, :video => {:title => ""}
    end
    
    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should render the form again" do
      response.should render_template("videos/form")
    end
    
    it "should assign the video to @video" do
      assigns[:video].title.should == ""
      assigns[:video].id.should == @video.id
    end
    
    it "should have errors on @video" do
      assigns[:video].errors.should_not be_empty
    end
  end
  
  describe "#update when properties change" do

    before(:each) do
      login_as_admin
      @video = Factory(:video)
      @video.descriptors.should be_empty
      @video.properties << DescriptorValue.find( :first )
      @video.save!
      @video.descriptors.should_not be_empty
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should change properties as indicated" do
      descriptor_value_ids = [ 1, 3, 5 ].sort
      put :update, :id => @video.id,
                   :descriptor_value => descriptor_value_ids
      response.should redirect_to(video_path(@video.id))
      @video.reload.descriptors.map( &:integer_value ).sort.
        should == descriptor_value_ids
    end

    it "should allow all properties to be removed" do
      put :update, :id => @video.id,
                    :descriptor_value => []
      response.should redirect_to(video_path(@video.id))
      @video.reload.descriptors.should be_empty
    end

    it "should handle invalid properties" do
      put :update, :id => @video.id, :descriptor_value => [ -1 ]
      response.code.should == "400"
    end

    it "should handle bizzare properties" do
      put :update, :id => @video.id,
                    :descriptor_value => "foobar"
      response.code.should == "400"

      put :update, :id => @video.id,
                    :descriptor_value => [ "foobar" ]
      response.code.should == "400"
    end

  end

  describe "#destroy with valid params" do
    before(:each) do
      login_as_admin
      @video = Factory(:video)
    end
    
    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    def do_delete
      delete :destroy, :id => @video.id
    end
    
    it "should delete the video" do
      lambda{ do_delete }.should change(Video, :count).by(-1)
    end
    
    it "should redirect to the videos page" do
      do_delete
      response.should redirect_to(videos_path)
    end
    
    it "should set the flash" do
      do_delete
      flash[:notice].should_not be_nil
    end
  end
  
  describe "#destroy with invalid params" do
    before(:each) do
      delete :destroy, :id => 0
    end
    
    it "should redirect to the videos page" do
      response.should redirect_to(videos_path)
    end
    
    it "should set the flash" do
      flash[:error].should_not be_nil
    end
  end

  describe "#public_only?" do

    it "should be true if not logged in" do
      get :index
      controller.send(:public_only?).should be_true
    end

    it "should be false if logged in as admin" do
      login_as_admin
      get :index
      controller.send(:public_only?).should be_false
    end

    it "should be false if logged in as cataloger" do
      login_as_cataloger
      get :index
      controller.send(:public_only?).should be_false
    end

  end

  describe "#video_ids_method" do

    it "should return public videos if public_only?" do
      get :index
      controller.send(:video_ids_method).should == :public_videos
    end

    it "should return all videos if !public_only?" do
      login_as_cataloger
      get :index
      controller.send(:video_ids_method).should == :all_videos
    end

  end

  describe "#videos_method" do

    it "should return public videos if public_only?" do
      get :index
      controller.send(:videos_method).should == :public_videos
    end

    it "should return all videos if !public_only?" do
      login_as_cataloger
      get :index
      controller.send(:videos_method).should == :all_videos
    end

  end

  describe "#viz_condition" do

    it "should return empty if !public_only?" do
      login_as_cataloger
      get :index
      controller.send(:viz_condition).should be_empty
    end

    it "should restrict videos if public_only?" do
      get :index
      controller.send(:viz_condition).should == { :public => true }
    end

  end

  describe "#duration_to_int_value" do

    it "nil if nil" do
      get :index
      controller.send(:duration_to_int, nil, Object, "key").should be_nil
    end

    it "nil if empty" do
      get :index
      controller.send(:duration_to_int, "", Object, "key").should be_nil
    end

    it "nil if blank" do
      get :index
      controller.send(:duration_to_int, " \t", Object, "key").should be_nil
    end

    it "should add errors if bogus" do
      get :index
      Object.should_receive(:errors).and_return(Object)
      Object.should_receive(:add).once
      controller.send(:duration_to_int, "a", Object, "key").should be_nil
    end

    it "should convert correctly if clean" do
      get :index
      controller.send(:duration_to_int, "02:03:04", Object, "key").should == 7384
    end

  end

  describe "#render_nothing" do
    integrate_views
    it "should render nothing" do
      login_as_cataloger
      get :home, :style => "none"
      response.code.should == "200"
      response.body.should be_blank
    end
  end

  describe "pretty 404s" do
    it "should raise pretty 404" do
      pending
      login_as_admin
      rescue_action_in_public!
      ExceptionNotifier.should_receive(:deliver_exception_notification)
      controller.should_receive(:edit).and_raise(ActionController::UnknownAction)
      get :edit, :id => 1
      response.code.should == "404"
    end
  end

end
