Rails.configuration.after_initialize do 
 
  class Tr8n::Config

    def self.user_name(user)
      user.default_pseud.id.to_s
    end
 
    def self.user_id(user)
      user.id
    end
 
    def self.current_user_is_translator?
      true
    end
      
  end
 
end
