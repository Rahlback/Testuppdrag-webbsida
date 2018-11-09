require 'win32ole'

class Mail
    def initialize()
        @app = WIN32OLE.new('Outlook.Application')
    end

    def create_mail(subject, to, body='', cc='', bcc='', attachments=[], deliveryTime='')
        mail = @app.CreateItem(0)
        mail.Subject = subject
        mail.Body = body
        mail.To = to
        mail.CC = cc
        mail.BCC = bcc
        mail.DeferredDeliveryTime = deliveryTime

        attachments.each do |file_path|
            puts file_path
            mail.Attachments.Add(file_path, 1)
        end
        mail.Save
        mail.Send
    end

	def create_simple_mail(subject, to, body='')
		mail = @app.CreateItem(0)
		mail.Subject = subject
		mail.Body = body
		mail.To = to

		mail.Save
		mail.Send
	end


end
# puts inbox.ole_methods
# inbox.Display

# puts inbox.get_ole_methods
# mail.ole_methods.each do |method|
    # puts method.to_s
# end

# post = mail.CreateItem(0)
# post.Subject = 'LOL'
# post.Body = ''
# post.To = 'rasmus.ahlback@gmail.com'
# # post.CC = 'ord@insektionen.se'
# # post.BCC = 'rahlback@kth.se'
# post.Attachments.Add('C:\Users\Rasmus\Documents\Insektionen\code\fill forms\generated pub stuff\Festanmälan Kistan 2.0 2018-02-27.pdf', 1)
# post.DeferredDeliveryTime = "2019-01-01 10:00"
# post.Save

# puts post.ole_methods

# arr = post.ole_methods
#
# tArray = []
# arr.each do |t|
#     tArray << t.to_s
# end
#
# tArray.sort!.uniq!
# puts tArray
