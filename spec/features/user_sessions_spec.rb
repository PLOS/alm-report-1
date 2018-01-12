require "rails_helper"

#TODO:FIX
describe "user sessions", skip: true, :type => :feature do
  # it "signs in as Persona user", js: true do
  #   ENV["OMNIAUTH"] = "persona"
  #   sign_in
  #   expect(page).to have_content "Joe Smith"
  # end

  it "signs in as CAS user", js: true do
    sign_in
    expect(page).to have_content "Joe Smith"
  end

  it "sign in error as CAS user", js: true do
    auth = OmniAuth.config.mock_auth[:default]
    OmniAuth.config.mock_auth[:default] = :invalid_credentials

    sign_in
    expect(page).to have_content "Your Article List"
    expect(page).to have_content "Could not authenticate you from CAS"

    OmniAuth.config.mock_auth[:default] = auth
  end

  it "signs in as ORCID user", js: true do
    ENV["OMNIAUTH"] = "orcid"
    sign_in
    expect(page).to have_content "Joe Smith"
  end

  it "signs in as Github user", js: true do
    ENV["OMNIAUTH"] = "github"
    sign_in
    expect(page).to have_content "Joe Smith"
  end

  it "signs out as user", js: true do
    sign_in
    sign_out
    expect(page).to have_content "Your Article List"
  end
end
