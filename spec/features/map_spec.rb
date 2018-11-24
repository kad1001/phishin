# frozen_string_literal: true
require 'rails_helper'

feature 'Venues page', :js do
  scenario 'visit Venues page' do
    visit map_path

    within('#title_box') do
      expect_content('Find shows near:', 'within', 'miles', 'within timeframe')
      expect_css('#map_search_term', '#map_search_distance', '#map_date_start', '#map_date_stop')
    end

    within('#content_box') do
      expect_css('#google_map')
    end
  end
end
