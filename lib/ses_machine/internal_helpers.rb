# encoding: utf-8

module SesMachine #:nodoc:
  class InternalHelpers #:nodoc:
    class << self
      
      def get_keywords(array)
        array.map{|w| w.mb_chars.downcase.to_s}.uniq.delete_if{|w| w.mb_chars.size < 3}
      end
    end
  end
end
