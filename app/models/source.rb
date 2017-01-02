require 'net/imap'

class Source < ApplicationRecord
  belongs_to :user

  validates :username, uniqueness: { case_sensitive: false }
  validates :username, :password, :port, :address, :ssl, presence: true
  validates :port, numericality: { only_integer: true }

  def works?
    !mail.disconnected?
  rescue Net::IMAP::NoResponseError => e
    raise e unless e =~ /Authentication failed./
    false
  end

  def mails flags: %w(UNSEEN)
    mail.search(flags).map do |message_id|
      Mail.new(mail.fetch(message_id, "RFC822")[0].attr['RFC822'])
    end
  end

  def mail
    @mail ||= 
      begin
        i = Net::IMAP.new(self.address, self.port, false)
        i.starttls if self.ssl and self.port == 143
        i.authenticate(self.authentication, self.username, self.password) 
        i.examine('INBOX')
        i
      end
  end

end
