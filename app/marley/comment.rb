require 'akismetor'

module Marley

  class Comment < ActiveRecord::Base
    include Marley::Configuration
    extend  Marley::Configuration

    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => comments_database_path)

    belongs_to :post

    named_scope :recent,   :order => 'created_at DESC', :limit => 50
    named_scope :ham, :conditions => { :spam => false }

    validates_presence_of :author, :email, :body, :post_id
    validate :author_is_human?

    before_create :fix_urls, :check_spam
    
    attr_accessor :human_verification_answer
    
    private

    # See http://railscasts.com/episodes/65-stopping-spam-with-akismet
    def akismet_attributes
      {
        :key                  => marley_config.akismet.key,
        :blog                 => marley_config.akismet.url,
        :user_ip              => self.ip,
        :user_agent           => self.user_agent,
        :referrer             => self.referrer,
        :permalink            => self.permalink,
        :comment_type         => 'comment',
        :comment_author       => self.author,
        :comment_author_email => self.email,
        :comment_author_url   => self.url,
        :comment_content      => self.body
      }
    end
    
    def check_spam
      self.checked = true
      self.spam = Akismetor.spam?(akismet_attributes)
      true # return true so it doesn't stop save
    end

    # TODO : Unit test for this
    def fix_urls
      return unless self.url
      self.url.gsub!(/^(.*)/, 'http://\1') unless self.url =~ %r{^http://} or self.url.empty?
    end
    
    class << self
      attr_reader :human_verification_question
      
      def set_human_verification_question(question, answer)
        @human_verification_question = question
        @human_verification_answer = answer
      end
      
      def check_human_verification_answer(answer)
        answer == @human_verification_answer
      end
    end
    
    def author_is_human?
      if self.class.human_verification_question
        unless self.class.check_human_verification_answer(human_verification_answer)
          errors.add(:human_verification_answer, "is incorrect")
        end
      end
    end
  end

end
