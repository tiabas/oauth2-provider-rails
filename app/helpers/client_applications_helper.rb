module ClientApplicationsHelper

  def client_types_options
    list = []
    ClientApplication::CLIENT_TYPES.map do |k, v|
      list << [k, v]
    end
    list
  end
end
