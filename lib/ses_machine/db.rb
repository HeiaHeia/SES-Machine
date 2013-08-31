# -*- encoding : utf-8 -*-


module SesMachine #:nodoc:
  class DB #:nodoc:
    class << self

      def get_keywords(array)
        array.map{|w| w.downcase.to_s}.uniq.delete_if{|w| w.size < 3}
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

      def update_monthly_stats
        map = <<-JS
    function() {

      var date = new Date(this['_id'])

      var key = {
        year: date.getFullYear(),
        month: date.getMonth() + 1
      };
      var value = this.value;

      emit(key, value);
    }
    JS

        reduce = <<-JS
    function(key, values) {
      var sum = {total: 0};

      types.forEach(function(type) {
        sum[type] = 0;
      });

      values.forEach(function(value) {
        for(var type in value) {
          sum[type] += value[type];
        }
      });

      return sum;
    }
    JS
        t = SesMachine.database['daily_stats']
        t.map_reduce(map, reduce, :out => {'merge' => 'monthly_stats'}, :raw => true, :scope => {'types' => SesMachine::Bounce::TYPES.values})
      end

    end
  end
end
