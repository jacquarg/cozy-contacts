fs = require 'fs'
path = require 'path'
Contact = require '../models/contact'
Config  = require '../models/config'
Tag = require '../models/tag'
WebDavAccount = require '../models/webdavaccount'
async   = require 'async'
cozydb = require 'cozydb'

getTemplateExtension = ->
    # If run from build/, templates are compiled to JS
    # otherwise, they are in jade
    filePath = path.resolve __dirname, '../views/index.js'
    runFromBuild = fs.existsSync filePath
    extension = if runFromBuild then 'js' else 'jade'
    return extension

getImports = (callback) ->
    async.parallel [
        Config.getInstance
        (cb) -> cozydb.api.getCozyInstance cb
        (cb) -> cozydb.api.getCozyTags cb # All tags values in cozy.
        (cb) -> WebDavAccount.first cb
        Tag.all # tags instances (with color).
    ], (err, res) ->
        [config, instance, tags, webDavAccount, tagInstances] = res

        # Remove this fix once cozydb is fixed:
        # https://github.com/cozy/cozydb/issues/6
        if tags?
            tags = tags.filter (value) ->
                Boolean(value)
        else
            tags = []

        locale = instance?.locale or 'en'
        if webDavAccount?
            webDavAccount.domain = instance?.domain or ''

        callback null,
            config:        config
            locale:        locale
            tags:          tags
            webDavAccount: webDavAccount
            inittags:      tagInstances


module.exports =

    index: (req, res) ->
        getImports (err, imports) ->
            return res.error 500, 'An error occured', err if err

            extension = getTemplateExtension()

            res.render "index.#{extension}",
                imports: JSON.stringify(imports)
                locale:  imports.locale


    setConfig: (req, res) ->
        Config.set req.body, (err, config) ->
            return res.error 500, 'An error occured', err if err
            res.send config
