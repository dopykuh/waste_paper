require 'net/imap'

class Source < ApplicationRecord
  belongs_to :user
  has_many :entries

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
      m = Mail.new(mail.fetch(message_id, "RFC822")[0].attr['RFC822'])
      block_given? ? yield(m, message_id) : m
    end
  end

  def entries!
    processing_dir!
    mails do |m, message_id|
      m.attachments.each do |attachment|
        self.entries << Entry.new(attachment: attachment)
      end
      mail.copy(message_id, 'INBOX.Archive')
      mail.store(message_id, '+FLAGS', [:Deleted])
    end
    mail.expunge
  end

  def processing_dir!
    return if mail.list('INBOX.', 'Archive')
    mail.create('INBOX.Archive')
  end

  def mail
    @mail ||= 
      begin
        i = Net::IMAP.new(self.address, self.port, false)
        i.starttls if self.ssl and self.port == 143
        i.authenticate(self.authentication, self.username, self.password) 
        i.select('INBOX')
        i
      end
  end
end
