require 'rails_helper'

feature "User logs in and logs out" do

  # `js: true` spec metadata means this will run using the `:selenium` browser driver configured in spec/support/capybara.rb
  scenario "with correct details", js: true do

    create(:user, email: "someone@example.tld", password: "somepassword")

    visit "/"

    click_link "Log in"
    expect(page).to have_css("h2", text: "Log in")
    expect(current_path).to eq(new_user_session_path)

    login "someone@example.tld", "somepassword"

    expect(page).to have_css("h1", text: "Welcome to RSpec Rails Examples")
    expect(current_path).to eq "/"
    expect(page).to have_content "Signed in successfully"
    expect(page).to have_content "Hello, someone@example.tld"

    click_button "Log out"

    expect(current_path).to eq "/"
    expect(page).to have_content "Signed out successfully"
    expect(page).not_to have_content "someone@example.tld"

  end

  scenario "unconfirmed user cannot login" do

    create(:user, skip_confirmation: false, email: "e@example.tld", password: "test-password")

    visit new_user_session_path

    login "e@example.tld", "test-password"

    expect(current_path).to eq(new_user_session_path)
    expect(page).not_to have_content "Signed in successfully"
    expect(page).to have_content "You have to confirm your email address before continuing"
  end

  scenario "locks account after 10 failed attempts" do

    email = "someone@example.tld"
    create(:user, email: email, password: "somepassword")

    visit new_user_session_path

    (1..8).each do |attempt_num|
      login email, "wrong-password #{attempt_num}"
      expect(page).to have_content "Invalid email or password"
    end

    login email, "wrong-password 9"
    expect(page).to have_content "You have one more attempt before your account is locked"

    login email, "wrong-password 10"
    expect(page).to have_content "Your account is locked."

  end

  private

  def login(email, password)
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Log in"
  end

end