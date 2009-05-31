
Factory.define :message do |m|
  m.subject 'message subject'
  m.body 'Message body.'
  m.folder Message::INBOX
  m.unread true  
end
