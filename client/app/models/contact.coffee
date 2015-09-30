request = require 'lib/request'

module.exports = class Contact extends Backbone.Model

    idAttribute: '_id'

    urlRoot: 'contacts'

    defaults:
        n:          ';;;;'
        datapoints: []


    parse: (attrs) ->
        delete attrs[key] for key, value of attrs when value is ''

        if (url = attrs.url)
            delete attrs.url
            attrs.datapoints.unshift
                name:  'url'
                type:  'main'
                value: url

        datapoints = new Backbone.Collection()
        datapoints.comparator = 'name'
        datapoints.add attrs.datapoints if attrs.datapoints
        attrs.datapoints = datapoints

        return attrs


    sync: (method, model, options) ->
        options.attrs = model.toJSON()

        datapoints = model.attributes.datapoints.toJSON()
        mainUrl = _.findWhere datapoints, {name: 'url'}

        if mainUrl
            options.attrs.datapoints = _.without datapoints, mainUrl
            options.attrs.url = mainUrl.value

        super


    toJSON: ->
        _.extend {}, super, datapoints: @attributes.datapoints.toJSON()


    savePicture: (dataURL, callback) ->
        callback = callback or ->

        unless @has 'id'
            return callback new Error 'Model should ahve been saved once.'

        #transform into a blob
        binary = atob dataURL.split(',')[1]
        array = []
        for i in [0..binary.length]
            array.push binary.charCodeAt i

        blob = new Blob [new Uint8Array(array)], type: 'image/jpeg'

        data = new FormData()
        data.append 'picture', blob
        data.append 'contact', JSON.stringify @toJSON()

        markChanged = (err, body) =>
            if err
                console.error err
            else
                @set 'pictureRev', true

        path = "contacts/#{@get 'id'}/picture"
        request.put path, data, markChanged, false
        callback()

