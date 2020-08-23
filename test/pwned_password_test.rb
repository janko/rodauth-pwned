require "test_helper"

describe "Rodauth pwned_password feature" do
  it "disallows pwned password on create account" do
    rodauth do
      enable :pwned_password, :create_account
      require_login_confirmation? false
      require_password_confirmation? false
    end
    roda do |r|
      r.rodauth
      r.root { view(content: "") }
    end

    visit "/create-account"
    fill_in "Login", with: "foo@example.com"
    fill_in "Password", with: "password"
    click_on "Create Account"

    assert_equal "/create-account", page.current_path
    assert_equal "There was an error creating your account", page.find("#error_flash").text
    assert_match "this password has previously appeared in a data breach", page.html

    fill_in "Password", with: "much more secure password"
    click_on "Create Account"

    assert_equal "/", page.current_path
    assert_equal "Your account has been created", page.find("#notice_flash").text
  end

  it "allows setting maximum allowed pwned count" do
    pwned_count = nil
    rodauth do
      enable :pwned_password, :create_account
      password_allowed_pwned_count { pwned_count }
      require_login_confirmation? false
      require_password_confirmation? false
    end
    roda do |r|
      r.rodauth
      r.root { view(content: "") }
    end

    pwned_count = Pwned.pwned_count("password123") - 10
    visit "/create-account"
    fill_in "Login", with: "foo@example.com"
    fill_in "Password", with: "password123"
    click_on "Create Account"

    assert_equal "/create-account", page.current_path
    assert_equal "There was an error creating your account", page.find("#error_flash").text
    assert_match "this password has previously appeared in a data breach", page.html

    pwned_count = Pwned.pwned_count("password123") + 10
    fill_in "Password", with: "password123"
    click_on "Create Account"

    assert_equal "/", page.current_path
    assert_equal "Your account has been created", page.find("#notice_flash").text
  end

  it "allows configuring pwned password error message" do
    rodauth do
      enable :pwned_password, :create_account
      password_pwned_message { "You have been PWNED!" }
      require_login_confirmation? false
      require_password_confirmation? false
    end
    roda do |r|
      r.rodauth
      r.root { view(content: "") }
    end

    visit "/create-account"
    fill_in "Login", with: "foo@example.com"
    fill_in "Password", with: "password"
    click_on "Create Account"

    assert_equal "/create-account", page.current_path
    assert_equal "There was an error creating your account", page.find("#error_flash").text
    assert_match "You have been PWNED!", page.html
  end

  it "considers the password not pwned on request errors" do
    exception = nil
    rodauth do
      enable :pwned_password, :create_account
      pwned_request_options open_timeout: 0
      on_pwned_error { |error| exception = error }
      require_login_confirmation? false
      require_password_confirmation? false
    end
    roda do |r|
      r.rodauth
      r.root { view(content: "") }
    end

    visit "/create-account"
    fill_in "Login", with: "foo@example.com"
    fill_in "Password", with: "password"
    click_on "Create Account"

    assert_kind_of Pwned::Error, exception
    assert_equal "/", page.current_path
    assert_equal "Your account has been created", page.find("#notice_flash").text
  end
end
