require "spec_helper"

#TODO:FIX
describe "preview list from dois", skip: true, type: :feature, vcr: true do
  it "loads the articles result page", js: true do
    visit "/"

    click_link "By DOI/PMID"

    fill_in "doi-pmid-1", with: "10.1371/journal.pone.0021143"

    click_button "Add to My List"

    expect(page).to have_content "Independent Origins of Cultivated Coconut"
  end
end
