# encoding: utf-8

module SesMachine #:nodoc:
  class Bounce #:nodoc:

    TYPES = {
      :email_sent => 0,
      :unknown => 1,
      :soft_bounce => 2,
      :hard_bounce => 3,
      :spam_complaint => 4,
      :auto_responder => 5
    }
  end
end
