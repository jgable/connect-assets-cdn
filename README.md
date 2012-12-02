connect-assets-cdn [![Build Status](https://secure.travis-ci.org/jgable/connect-assets-cdn.png)](http://travis-ci.org/jgable/connect-assets-cdn)
==================

A helper module for connect-assets to upload your files to a CDN (like Amazon S3)

### Installation

`npm install connect-assets-cdn`

### Usage

    assets = require 'connect-assets'
    {AssetsCDN} = require 'connect-assets-cdn'
    
    # Snip ...
    
    app.use assets
    	servePath: '//s3.amazonaws.com/S3_Bucket'
    
    # You should probably only upload for production
    if process.env.NODE_ENV == "production"

    	cdn = new AssetsCDN 
    		assets: assets
    		key: "S3_Key"
    		secret: "S3_Secret"
    		bucket: "S3_Bucket"

    	cdn.upload (err, uploadedPaths) ->
    		throw err if err

    		app.listen 3000, (err) ->
    			console.log "Server started"

### TODO:

* Check if files exist already on CDN before uploading

### Thanks

Made possible thanks to [connect-assets](https://github.com/TrevorBurnham/connect-assets), [s3-client](https://github.com/superjoe30/node-s3-client), [knox](https://github.com/learnboost/knox).
    
### Copyright

Created by [Jacob Gable](http://jacobgable.com).  MIT License; no attribution required.