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
    --ke4
    x
    --mb14
    }

    MAJOR_DEV = %{
    --llh1
    x
    --ke4
    --mb14
    x
    x
    }


    VERSION = "3.0.0.#{MAJOR_DEV.scan(/\sx/i).size}.#{MINOR_DEV.scan(/\sx/i).size}"
  end
end
