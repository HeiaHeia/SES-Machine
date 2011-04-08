# encoding: utf-8

module SesMachine #:nodoc:
  class DB #:nodoc:
    class << self
      
      def get_keywords(array)
        array.map{|w| w.mb_chars.downcase.to_s}.uniq.delete_if{|w| w.mb_chars.size < 3}
      end

      def update_daily_stats
        map = <<-JS
    function() {
      var self = this;
      var key = this.date - (this.date % 86400000);
      var value = {total: 1};

      types.forEach(function(type) {
        value[type] = self.bounce_type == type ? 1 : 0;
      });

      emit(key, value);
    }
    JS

        reduce = <<-JS
    function(key, values) {
      var sum = {};
      var total = 0;
      types.forEach(function(type) {
        sum[type] = 0;
      });

      values.forEach(function(value) {
        for(var type in value) {
          sum[type] += value[type];
        }
      });

      types.forEach(function(type) {
        total += sum[type];
      });
      sum['total'] = total;

      return sum;
    }
    JS
        t = SesMachine.database['mails']
        t.map_reduce(map, reduce, :out => {'merge' => 'daily_stats'}, :raw => true, :scope => {'types' => SesMachine::Bounce::TYPES.values})
      end

    end
  end
end