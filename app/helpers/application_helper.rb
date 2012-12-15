module ApplicationHelper
	def flash_notifications
      message = flash[:error] || flash[:notice]

      if message
        type = flash.keys[0].to_s
        javascript_tag %Q{noty({ text:"#{message}", type:"#{type}", layout:"bottom", theme: 'defaultTheme', timeout : 1500});}
      end
  	end

  	

end
