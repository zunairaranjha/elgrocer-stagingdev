# frozen_string_literal: true

describe 'loggin in as an admin' do
  let(:email) { 'w@rst-it.com' }
  let(:password) { 'awesomeapss' }

  let!(:admin) do
    FactoryBot.create(:admin_user,
                      email: email,
                      password: password,
                      password_confirmation: password,
                      current_time_zone: 'Asia/Dubai')
  end

  before :each do
    visit '/admin'
  end

  it "doesn't log when wrong credentials are given" do
    within '#session_new' do
      fill_in 'admin_user_email', with: email
      fill_in 'admin_user_password', with: "#{password}something-else"
      click_button 'Login'
    end

    expect(page).not_to have_content 'Signed in successfully'
  end
end
