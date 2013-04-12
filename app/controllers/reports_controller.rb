class ReportsController < ApplicationController

  # Creates a new report based on the DOIs stored in the session, and redirects to
  # display it.
  def generate
    dois = session[:dois]
    if dois.nil?
      
      # TODO: user-friendly error handling
      raise "No DOIs saved in session!"
    end

    @report = Report.new
    if !@report.save
      raise "Error saving report"
    end
    
    # Convert to array, sorted in descending order by timestamp, then throw away the timestamps.
    dois = dois.sort_by{|doi, timestamp| -timestamp}.collect{|x| x[0]}
    @report.add_all_dois(dois)
    if @report.save
      redirect_to :action => "metrics", :id => @report.id
    else
      
      # TODO
    end
  end


  # Loads a report based on the report_id, and sets some other common variables used by
  # the reports pages.
  def load_report(id)
    @tab = :view_report
    @report = Report.find(id)

    # Save the report DOIs in the session (overwriting whatever might already be there).
    saved_dois = {}
    @report.report_dois.each do |report_doi|
      saved_dois[report_doi.doi] = report_doi.sort_order
    end
    session[:dois] = saved_dois
  end
  
  
  def metrics
    load_report(params[:id])
    @report_sub_tab = :metrics
    @title = "Sample Metrics"
    @total_found = @report.report_dois.length
    set_paging_vars(params[:current_page], 5)
    
    # Create a new array for display that is only the articles on the current page,
    # to limit what we have to load from solr and ALM.
    @dois = @report.report_dois[(@start_result) - 1..(@end_result - 1)]
    i = @start_result

    alm_data = AlmRequest.get_data_for_articles(@dois)
    solr_data = SolrRequest.get_data_for_articles(@dois)

    @dois.each do |doi|
      doi.solr = solr_data[doi.doi]
      doi.alm = alm_data[doi.doi]
      
      # Set the display index as a property for rendering.
      doi.display_index = i
      i += 1
    end
  end
  
  
  def visualizations
    load_report(params[:id])
    @report_sub_tab = :visualizations
    @title = "Report Visualizations"
    @report.load_articles_from_solr
    alm_data = AlmRequest.get_data_for_articles(@report.report_dois)
    @report.report_dois.each {|report_doi| report_doi.alm = alm_data[report_doi.doi]}
    generate_data_for_bubble_charts
  end


  # Populates @article_usage_citations_age_data and @article_usage_mendeley_age_data, used from
  # javascript to generate the bubble charts.
  def generate_data_for_bubble_charts
    @article_usage_citations_age_data = []
    @article_usage_mendeley_age_data = []
    @article_usage_citations_age_data << ["Title", "Months", "Total Views", "Journal", "Scopus"]
    @article_usage_mendeley_age_data << ["Title", "Months", "Total Views", "Journal", "Mendeley"]
    @report.report_dois.each do |report_doi|
      days = (Date.today - report_doi.solr["publication_date"]).to_i
      months = days / 30

      # TODO: uncomment when ALM bug is fixed; for now use total_usage which is mostly from PMC.
#      usage = report_doi.alm[:plos_html]
      usage = report_doi.alm[:total_usage]
      @article_usage_citations_age_data << [report_doi.solr["title"], months, usage,
          report_doi.solr["cross_published_journal_name"][0], report_doi.alm[:scopus_citations]]
      @article_usage_mendeley_age_data << [report_doi.solr["title"], months, usage,
          report_doi.solr["cross_published_journal_name"][0], report_doi.alm[:mendeley]]
    end
  end
  
end
