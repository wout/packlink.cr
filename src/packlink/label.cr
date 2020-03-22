struct Packlink
  struct Label < Base
    will_list "shipments/:id/labels"

    def self.all(id : String)
      all({id: id})
    end
  end
end
