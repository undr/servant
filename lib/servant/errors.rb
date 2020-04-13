module Servant
  class Errors < ActiveModel::Errors
    def freeze
      @messages = without_default_proc(messages)
      @details = without_default_proc(details)

      messages.each do |code, _messages|
        code.freeze
        _messages.each(&:freeze)
        _messages.freeze
      end

      messages.freeze
      self
    end
  end
end
