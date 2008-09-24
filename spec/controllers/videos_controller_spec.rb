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

    fixtures :descriptors, :descriptor_types, :descriptors_videos, :videos

    before(:each) do
      get :index
    end
    
    it "should return a successful response" do
      response.should be_success
    end

    it "should set current from descriptor_type if given" do
      type = DescriptorType.find :first
      get :index, :descriptor_type_id => type.id
      assigns[:current].should == type
    end

    it "should set current from descriptor if given" do
      d = Descriptor.find :first
      d.should_not be_nil
      get :index, :descriptor_id => d.id
      assigns[:current].should == d
    end

    it "should filter videos by descriptor if given" do
      d = Descriptor.find :first
      d.should_not be_nil
      get :index, :descriptor_id => d.id
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
      pending
      assigns[:video].should_not be_nil
      assigns[:video].should be_an_instance_of(Video)
      assigns[:video].should be_new_record
      assigns[:video].assets[0].uri.should == "file:///" + @filename
    end
  end
  
  describe "#new, when the filename parameter refers to a file outside the videos directory" do    
    it "should return a 404" do
      pending
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
  
  describe "#update when descriptors change" do

    fixtures :descriptor_types, :descriptors

    before(:each) do
      login_as_admin
      @video = Factory(:video)
      @video.descriptors.should be_empty
      @video.descriptors << Descriptor.find( :first )
      @video.save!
      @video.descriptors.should_not be_empty
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should change descriptors as indicated" do
      descriptor_ids = [ 1, 3, 5 ].sort
      put :update, :id => @video.id,
                   :"descriptor" => descriptor_ids
      response.should redirect_to(video_path(@video.id))
      @video.reload.descriptors.map( &:id ).sort.should == descriptor_ids
      
    end

    it "should allow all descriptors to be removed" do
      
      put :update, :id => @video.id,
                    :"descriptor" => []
      response.should redirect_to(video_path(@video.id))
      @video.reload.descriptors.should be_empty
    end

    it "should allow all descriptors to be removed via a special field" do
      put :update, :id => @video.id,
                    :"descriptors_passed" => true
      response.should redirect_to(video_path(@video.id))
      @video.reload.descriptors.should be_empty
    end

    it "should handle invalid descriptors" do
      put :update, :id => @video.id,
                    :"descriptor" => [ -1 ]
      response.code.should == "400"
    end

    it "should handle bizzare descriptors" do
      put :update, :id => @video.id,
                    :"descriptor" => "foobar"
      response.code.should == "400"

      put :update, :id => @video.id,
                    :"descriptor" => [ "foobar" ]
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
end
