class String
  #FIXME remove and convert to_f
  def to_d
    # to_f.to_d
    blank? ? 0.0.to_d : BigDecimal.new(self)
  end
end
