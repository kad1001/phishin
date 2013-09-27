class Tour < ActiveRecord::Base
  attr_accessible :name, :slug, :starts_on, :ends_on, :shows_count
  
  has_many :shows
  
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  def as_json
    {
      id: id,
      name: name,
      shows_count: shows_count,
      slug: slug
    }
  end
  
  def as_json_api
    {
      id: id,
      name: name,
      shows_count: shows_count,
      slug: slug,
      shows: shows.sort_by {|s| s.date }.as_json
    }
  end

end