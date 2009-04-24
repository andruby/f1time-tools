# = MathStatistics
#
# Author:: Joel Parker Henderson, joelparkerhenderson@gmail.com
# Copyright:: Copyright (c) 2006-2009 Joel Parker Henderson
# License:: CreativeCommons License, Non-commercial Share Alike
# License:: LGPL, GNU Lesser General Public License
#
# Also see http://pallas.telperion.info/ruby-stats/
 
 
module Enumerable
 
 
 # Examples
 #   [].sum => 0
 #   [1].sum => 1
 #   [1,2,3].sum => 5
 #
 # Example with default for empty
 #   [].sum(99) => 99
 #
 # Example with block
 #   [1,2,3].sum{|x| x*2} => 10
 #
 # This method is copied from rails to ensure compatibility.
 
  def sum(identity = 0, &block)
    return identity unless size > 0
    if block_given?
      map(&block).sum
    else
      inject { |sum, element| sum + element }
    end
  end
 
 
 # Examples
 #   [].mean => nil
 #   [1].mean => 1.0
 #   [1,2].mean => 1.5
 #   [1,2,9].mean => 4.0
 
 def mean
  size==0 ? nil : sum.to_f / size
 end
 
 
 # Examples
 #  [].median => nil
 #  [1].median => 1.0
 #  [1,2].median => 1.5
 #  [1,2,9].mean => 2.0
 
 def median
  size==0 ? nil : ((0==self.size%2) ? sort[size/2-1,2].mean : sort[self.size/2].to_f)
 end
 
 
 # Examples
 #  [].sum_of_squares => 0
 #  [1].sum_of_squares => 1.0
 #  [1,2].sum_of_squares => 5.0
 #  [1,2,3].sum_of_squares => 14.0
 
 def sum_of_squares 
  size==0 ? 0 : inject(0){|sum,x|sum+(x*x)}
 end
 
 
 # Examples
 #   [].variance => nil
 #   [1].variance =>  0.0
 #   [1,2].variance => 0.25
 #   [1,2,3,4].variance => 1.25
   
 def variance
  size==0 ? nil : ( m=mean and sum_of_squares.to_f/size - m*m )
 end
 
 
 # Examples
 #   [].deviation => nil
 #   [1].deviation => 0.0
 #   [1,2].deviation => 0.5
 #   [2,2,4,2,2].deviation => 0.8
 
 def deviation 
  size==0 ? nil : Math::sqrt(variance)
 end
 
end