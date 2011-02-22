Rails.configuration.after_initialize do 
 
  class Tr8n::Config

    # BEGIN EVIL HACK COMMENT DON'T REMOVE
    # (it's only the comment that's evil, the rest is fine ;-)
    
    def self.user_name(user)
      user.default_pseud.name
    end
 
    def self.user_id(user)
      user.id
    end
 
    def self.guest_user?(user=current_user)
      user.nil?
    end

    def self.current_user_is_guest?
      guest_user?
    end

    def self.current_user_is_translator?
      !guest_user?
    end
      
    def self.current_user_is_admin?
      !guest_user?
    end
      
    def self.user_mugshot(user)
      user.default_pseud.icon.url()
    end

  # END EVIL HACK COMMENT DON'T REMOVE

  end
 
end
