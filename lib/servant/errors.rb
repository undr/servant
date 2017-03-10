module Servant
  class Errors < ActiveModel::Errors
    def freeze
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
