require 'active_model'
require 'pp'

require 'servant/exceptions'
require 'servant/errors'
require 'servant/context'
require 'servant/context_builder'
require 'servant/result'
require 'servant/base'
require 'servant/version'

module Servant
  extend self

  def boolean
    [FalseClass, TrueClass]
  end
end
