require "spec_helper"

# It is currently not possible to check the content of a CSV with Poltergeist:
# http://stackoverflow.com/q/15739423/790483

#TODO:FIX
describe "export report as csv", skip: true, type: :feature, vcr: true do
  def search(keyword)
      visit "/"
      fill_in "everything", with: keyword
      click_button "Search"
  end

  def preview
    expect(page).to have_button("Preview List (2)")
    find_button("Preview List (2)").click
  end

  def get_csv
    click_button "Create Report"

    expect(page).to have_content("Metrics Data")
    within(".report-downloads") do
      click_link("Metrics Data")
    end
    page.response_headers["Content-Type"].should eq("text/csv")
  end

  if Search.plos?
    it "downloads the csv", js: true do
      search("cancer")
      expect(page).to have_content "Cancer-Drug Associations: A Complex System"
      expect(page).to have_button("Preview List (0)", disabled: true)

      first(".article-info").find("input.check-save-article").click
      expect(page).to have_button("Preview List (1)")
      all(".article-info")[5].find("input.check-save-article").click

      preview

      get_csv
    end
  elsif Search.crossref?
    it "downloads the csv", js: true do
      search("A Future Vision for PLOS Computational Biology")

      first(".article-info").find("input.check-save-article").click
      expect(page).to have_button("Preview List (1)")
      click_link("3")
      all(".article-info")[12].find("input.check-save-article").click

      preview

      get_csv
    end
  end
end
