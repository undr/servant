class OldSchoolService < Servant::Base
  attr_reader :attr1, :attr2

  def initialize(attr1, attr2)
    @attr1 = attr1
    @attr2 = attr2
  end

  def perform
    'Value'
  end
end
