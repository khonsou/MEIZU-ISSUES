class Tag < ActiveRecord::Base
  has_many :taggings

  def self.get_issue_ids_for_tag_list(tag_list)
    return [] if tag_list.blank?
    tags = Tag.where(:name => tag_list.split(/,\s*/))
    taggings = Tagging.where(:taggable_type => 'Issue').where(:tag_id => tags.map{|t| t.id})
    taggings.map{|t|t.taggable_id}
  end
end
