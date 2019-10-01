angular.module('precisionFilters', []).filter 'round_down', ->
  (number) ->
    BigNumber(number).round(5, BigNumber.ROUND_DOWN).toF(5)
#     BigNumber(number).round(2, BigNumber.ROUND_DOWN).toF(2)
