require 'rails_helper'

RSpec.describe "photos/new", type: :view do
  before(:each) do
    assign(:photo, Photo.new(
      :image_data => "MyText",
      :user => nil,
      :description => "MyText"
    ))
  end

  it "renders new photo form" do
    render

    assert_select "form[action=?][method=?]", photos_path, "post" do

      assert_select "textarea[name=?]", "photo[image_data]"

      assert_select "input[name=?]", "photo[user_id]"

      assert_select "textarea[name=?]", "photo[description]"
    end
  end
end
