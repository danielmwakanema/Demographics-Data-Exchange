module LocationService
  def self.list_assigned_locations
    assigned_sites = LocationNpid.group("couchdb_location_id")
    locations = []

    (assigned_sites || []).each do |l|
      location = Location.find_by_couchdb_location_id(l.couchdb_location_id)
      location_tags = LocationTag.where("l.couchdb_location_id = ?",
                                        l.couchdb_location_id).joins("INNER JOIN location_tag_maps m
        ON m.location_tag_id = location_tags.location_tag_id
        INNER JOIN locations l ON l.location_id = m.location_id").select("location_tags.*")

      locations << {
        name: location.name,
        doc_id: location.couchdb_location_id,
        latitude: location.latitude,
        longitude: location.longitude,
        code: location.code,
        location_tags: location_tags.map(&:name),
      }
    end

    return locations
  end

  def self.get_locations(params)
    name = params[:name]

    # Build Location query
    if name.blank?
      query = Location
    else
      query = Location.where("name like (?)", "#{name}%")
    end

    page_size = (params[:page_size] or DEFAULT_PAGE_SIZE).to_i

    if params.has_key? :page
      offset = (params[:page] or 0).to_i * page_size
      query = query.offset(offset)
    end

    query = query.limit(page_size).order("name ASC")

    locations = []

    (query || []).each do |l|
      location_tags = LocationTag.where("l.couchdb_location_id = ?",
                                        l.couchdb_location_id).joins("INNER JOIN location_tag_maps m
        ON m.location_tag_id = location_tags.location_tag_id
        INNER JOIN locations l ON l.location_id = m.location_id").select("location_tags.*")

      locations << {
        name: l.name,
        doc_id: l.couchdb_location_id,
        latitude: l.latitude,
        longitude: l.longitude,
        code: l.code,
        location_tags: location_tags.map(&:name),
      }
    end

    return locations
  end

  private

  DEFAULT_PAGE_SIZE = 10
end
