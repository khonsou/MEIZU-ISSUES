ActiveSupport::XmlMini::PARSING.delete("symbol")
ActiveSupport::XmlMini::PARSING.delete("yaml")


module ActionView
 module Helpers #:nodoc:
   module TextHelper

     # truncate by display width.
     # 根据视觉宽度截取，length代表两个普通英文字符宽度倍数
     # use unicode-display_width gem
     
     def truncate(text, *args)
       options = args.extract_options!
       unless args.empty?
         ActiveSupport::Deprecation.warn('truncate takes an option hash instead of separate ' +
           'length and omission arguments', caller)

         options[:length] = args[0] || 30
         options[:omission] = args[1] || "..."
       end
       options.reverse_merge!(:length => 30, :omission => "...")

       if text
         l = options[:length] * 2 - options[:omission].display_width
         chars = text
         (chars.display_width > options[:length] ? slice(chars, 0, l) + options[:omission] : text).to_s
       end
     end

     private

     def slice(string, offset, width)
       chars = string.chars.to_a[offset..-1].to_a

       current_length = 0
       split_index = 0
       chars.each_with_index do |c, i|
         char_width = c.display_width
         break if current_length + char_width > width
         split_index = i+1
         current_length += char_width
       end

       split_index ||= chars.count
       head = chars[0, split_index].join
       head
     end
   end
 end
end
