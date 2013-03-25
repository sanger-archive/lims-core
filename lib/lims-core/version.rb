module Lims
  module Core
    # Test a way to increment version in a merged-friendly way
    # Each user need to add an x, in its appropriate section (this will
    # avoid collision)
    # and clear eventually the minor version of everybody .
    # Please leave the marker of other developper
    #
    MINOR_DEV = %{
    --llh1
    x
    x
    --ke4
    x
    x
    --mb14
    x

  }
    MAJOR_DEV = %{
    --llh1
    --ke4
    --mb14

}


    VERSION = "1.4.1.#{MAJOR_DEV.scan(/\sx/i).size}.#{MINOR_DEV.scan(/\sx/i).size}"
  end
end
