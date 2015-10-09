CompareContacts = require "lib/compare_contacts"
ContactViewModel = require 'views/models/contact'


# Collection of merge ViewModels.
# Automatically feed up with findSimilars algorythme.
module.exports = class Duplicates extends Backbone.Collection

    model: require 'views/models/merge'

    url: null # Local collection.

    # Initialize the collection with duplicates fund in the sepcified contacts
    # collection.
    findDuplicates: (collection) ->
        duplicates = CompareContacts.findSimilars collection.toJSON()
        duplicates.forEach (candidates) =>
            candidates = candidates.map (c) ->
                # Build a ViewModel instace from a contact's json.
                new ContactViewModel {
                    new: false
                }, {
                    model: collection.get c.id
                }

            # Create a merge ViewModel and add it to the collection,
            # initialize with the specified candidates ContactsViewModels.
            @add { candidates }
