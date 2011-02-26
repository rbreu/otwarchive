#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Tr8n::Translator < ActiveRecord::Base
  set_table_name :tr8n_translators

  belongs_to :user, :class_name => Tr8n::Config.user_class_name, :foreign_key => :user_id
  
  has_many  :translations,                  :class_name => "Tr8n::Translation",               :dependent => :destroy
  has_many  :translation_votes,             :class_name => "Tr8n::TranslationVote",           :dependent => :destroy
  has_many  :translation_key_locks,         :class_name => "Tr8n::TranslationKeyLock",        :dependent => :destroy
  has_many  :language_users,                :class_name => "Tr8n::LanguageUser",              :dependent => :destroy
  has_many  :languages,                     :class_name => "Tr8n::Language",                  :through => :language_users

  belongs_to :fallback_language,            :class_name => 'Tr8n::Language',                  :foreign_key => :fallback_language_id
    
  def self.for(user)
    return nil unless user and user.id 
    return nil if Tr8n::Config.guest_user?(user)
    return user if user.is_a?(Tr8n::Translator)
    
    Tr8n::Cache.fetch("translator_for_#{user.id}") do 
      find_by_user_id(user.id)
    end
  end
  
  def self.find_or_create(user)
    trn = find(:first, :conditions => ["user_id = ?", user.id])
    trn = create(:user => user) unless trn
    trn
  end

  def self.register(user = Tr8n::Config.current_user)
    return unless user
    
    translator = Tr8n::Translator.create(:user => user)
    Tr8n::LanguageUser.find(:all, :conditions => ["user_id = ?", user.id]).each do |lu|
      lu.update_attributes(:translator => translator)
    end
    translator
  end

  def update_level!(actor, new_level, reason = "No reason given")
    update_attributes(:level => new_level)
  end
  
  def enable_inline_translations!
    update_attributes(:inline_mode => true)
  end

  def disable_inline_translations!(actor = user)
    update_attributes(:inline_mode => false)
  end

  def switched_language!(language)
    lu = Tr8n::LanguageUser.create_or_touch(user || self, language)
    lu.update_attributes(:translator => self) unless lu.translator
  end

  def deleted_language_rule!(rule)
  end

  def added_language_rule!(rule)
  end

  def updated_language_rule!(rule)
  end

  def deleted_language_case!(lcase)
  end

  def added_language_case!(lcase)
  end

  def updated_language_case!(lcase)
  end

  def added_translation!(translation)
  end

  def updated_translation!(translation)
  end

  def deleted_translation!(translation)
  end

  def voted_on_translation!(translation)
  end

  def locked_translation_key!(translation_key, language)
  end

  def unlocked_translation_key!(translation_key, language)
  end

  def tried_to_perform_unauthorized_action!(action)
  end
  
  def enable_inline_translations?
    inline_mode == true
  end
  
  # all admins are always manager for all languages
  def manager?
    return true unless Tr8n::Config.site_user_info_enabled?
    return true if Tr8n::Config.admin_user?(user)
    return true if level >= Tr8n::Config.manager_level
    false
  end

  def name
    unless Tr8n::Config.site_user_info_enabled?
      translator_name = super
      return translator_name unless translator_name.blank?
      return "No Name"
    end  
    
    return "Deleted User" unless user
    user_name = Tr8n::Config.user_name(user)
    return "No Name" if user_name.blank?
    
    user_name
  end

  def gender
    unless Tr8n::Config.site_user_info_enabled?
      translator_gender = super
      return translator_gender unless translator_gender.blank?
      return "unknown"
    end  

    Tr8n::Config.user_gender(user)
  end

  def mugshot
    return super unless Tr8n::Config.site_user_info_enabled?
    return Tr8n::Config.silhouette_image unless user
    img_url = Tr8n::Config.user_mugshot(user)
    return Tr8n::Config.silhouette_image if img_url.blank?
    img_url
  end

  def link
    return super unless Tr8n::Config.site_user_info_enabled?
    return Tr8n::Config.default_url unless user
    Tr8n::Config.user_link(user)
  end

  def admin?
    # stand alone translators are always admins
    return true unless Tr8n::Config.site_user_info_enabled?
    
    return false unless user
    Tr8n::Config.admin_user?(user)
  end  

  def guest?
    return id.nil? unless Tr8n::Config.site_user_info_enabled?

    return true unless user
    Tr8n::Config.guest_user?(user)
  end  

  def level
    return 0 if super.nil?
    super
  end

  def title
    return 'admin' if admin?
    Tr8n::Config.translator_levels[level.to_s] || 'unknown'
  end

  def self.level_options
    @level_options ||= begin
      opts = []
      Tr8n::Config.translator_levels.keys.collect{|key| key.to_i}.sort.each do |key|
        opts << [Tr8n::Config.translator_levels[key.to_s], key.to_s]
      end
      opts
    end
  end

  def after_save
    Tr8n::Cache.delete("translator_for_#{user_id}")
  end

  def after_destroy
    Tr8n::Cache.delete("translator_for_#{user_id}")
  end

  def to_s
    name
  end
end
