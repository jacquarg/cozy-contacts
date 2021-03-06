americano = require 'americano'
path = require 'path'

module.exports =

    common:
        use: [
            americano.static path.resolve(__dirname, '../client/public'),
                maxAge: 86400000
            americano.bodyParser keepExtensions: true
            require('./helpers/shortcut')
            americano.errorHandler
                dumpExceptions: true
                showStack: true
        ]
        set:
            'views': './client/'

    development: [
        americano.logger 'dev'
    ]

    production: [
        americano.logger 'short'
    ]

    plugins: [
        'americano-cozy'
    ]
