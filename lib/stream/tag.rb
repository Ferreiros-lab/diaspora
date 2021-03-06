#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Tag < Stream::Base
  attr_accessor :tag_name, :people_page , :people_per_page

  def initialize(user, tag_name, opts={})
    self.tag_name = tag_name
    self.people_page = opts[:page] || 1
    self.people_per_page = 15
    super(user, opts)
  end

  def tag
    @tag ||= ActsAsTaggableOn::Tag.named(tag_name).first
  end

  def display_tag_name
    @display_tag_name ||= "##{tag_name}"
  end

  def tagged_people
    @people ||= ::Person.profile_tagged_with(tag_name).paginate(:page => people_page, :per_page => people_per_page)
  end

  def tagged_people_count
    @people_count ||= ::Person.profile_tagged_with(tag_name).count
  end

  def posts
    @posts ||= construct_post_query
  end

  def tag_name=(tag_name)
    @tag_name = tag_name.downcase.gsub('#', '')
  end

  private

  # @return [Hash]
  def publisher_opts
    {:open => true}
  end

  def construct_post_query
    posts = if user.present?
              StatusMessage.owned_or_visible_by_user(user)
            else
              StatusMessage.all_public
            end
    posts.tagged_with(tag_name, :any => true)
  end
end
