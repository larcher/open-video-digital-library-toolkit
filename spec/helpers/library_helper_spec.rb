require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LibraryHelper do
  
  def sort_ar( l )
    l.sort do |a,b|
      aid = a.id || a.object_id
      bid = b.id || b.object_id
      aid <=> bid
    end
  end

  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(LibraryHelper)
  end

  describe "#property_types_by_class" do
    
    it "should filter the property types variable by class" do
      assigns[:property_types] = @property_types = PropertyType.find(:all)
      @property_types << ( pt = PropertyType.new :property_class_id => 1 )

      helper.property_types_by_class( PropertyClass.find(1) ).should ==
        ( PropertyType.find_all_by_property_class_id(1) + [ pt ] )
    end

  end

  describe "#rights_details" do
    
    it "should return all the current rights details" do
      assigns[:rights_details] = @rights_details = RightsDetail.find(:all)

      @rights_details << ( rd = RightsDetail.new )

      helper.rights_details.should == ( RightsDetail.find(:all).to_a + [ rd ]  )

    end

  end

  describe "#descriptor_types" do
    
    it "should return all the current descriptor types" do
      assigns[:property_types] = @property_types =
        PropertyType.find( :all ).select { |pt| pt.property_class.range == "descriptor_value" }

      @property_types << ( pt = PropertyType.new( :property_class =>
                                                    PropertyClass.find( :first,
:conditions =>
                                                                          "range = 'descriptor_value'"
                                                                        )
                                                  ) )

      sort_ar( helper.descriptor_types ).
               should == sort_ar( [ pt ] +( PropertyType.find( :all ).
                                            select { |pt| pt.property_class.range ==
                                                        "descriptor_value" } ) )
    end

  end

  describe "#descriptor_values" do
    
    it "should return all the descriptor values for a given pt" do

      assigns[:property_types] = @property_types = PropertyType.find( :all )
      
      assigns[:descriptor_values] = @descriptor_values = DescriptorValue.find( :all )

      dt = @property_types.find { |pt| pt.property_class.range == "descriptor_value" }

      @descriptor_values << ( dv = DescriptorValue.new( :property_type_id => dt.id ) )

      sort_ar( helper.descriptor_values( dt ) ).
        should == sort_ar( [ dv ] + DescriptorValue.find( :all, :conditions =>"property_type_id = #{dt.id}" ) )
    end

  end

  describe "#default_descriptor_class" do

    it "should return a descriptor class type" do
      dcs = PropertyClass.find :all,
                                 :conditions => "range = 'descriptor_value'"
      dcs.include?( helper.default_descriptor_class ).should be_true
    end
    
  end

  describe "templates" do

    describe "descriptor types" do
    end

    describe "descriptor values" do

      describe "existing dts" do

        before(:each) do
          @dt = PropertyType.descriptor_types[0]
          @dv = helper.dv_template( @dt )
          helper.extend  ApplicationHelper
        end

        it "should reference the dt" do
          @dv.property_type_id.should == @dt.id.to_s
        end

        it "should have a template id" do
          @dv.id.should == "new_dv"
        end

      end

      describe "unsaved dts" do

        before(:each) do
          @dt = PropertyType.new
          @dv = helper.dv_template( @dt )
          helper.extend  ApplicationHelper
        end

        it "should reference the dt" do
          @dv.property_type_id.should =~ /^new_\d+$/
        end

        it "should have a template id" do
          @dv.id.should == "new_dv"
        end

      end

      describe "template dt" do

        before(:each) do
          @dt = helper.dt_template
          @dv = helper.dv_template( @dt )
          helper.extend  ApplicationHelper
        end

        it "should reference the dt" do
          @dv.property_type_id.should == "new_dt"
        end

        it "should have a template id" do
          @dv.id.should == "template_new_dv"
        end

      end

    end

  end

end