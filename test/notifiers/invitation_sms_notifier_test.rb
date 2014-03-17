require 'test_helper'

class InvitationSmsNotifierTest < ActionView::TestCase
  test "should construct message text" do
    senderName = 'Adam1'
    groupName = 'Adams Posse'
    invitationLink = 'http://www.knoda.com/groups/join?code=I1A4X82'
    m = InvitationSmsNotifier.message(senderName, groupName, invitationLink)
    assert m.length < 160
    assert m.length > (senderName.length + groupName.length + invitationLink.length)
  end

  test "should construct message text when groupname is long" do
    senderName = 'Adam1'
    groupName = 'Adams Posse with the P to the Pizzle'
    invitationLink = 'http://www.knoda.com/groups/join?code=I1A4X82'
    m = InvitationSmsNotifier.message(senderName, groupName, invitationLink)
    assert m.length < 160
  end  
end
