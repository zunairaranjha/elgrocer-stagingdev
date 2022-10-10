describe "homepage", :type => :feature do
  it "shows homepage without errors" do
    visit '/'
    expect(page.title).to have_content "Elgrocer"
  end
end