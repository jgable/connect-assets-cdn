connect-assets-cdn [![Build Status](https://secure.travis-ci.org/jgable/connect-assets-cdn.png)](http://travis-ci.org/jgable/connect-assets-cdn)
==================

A helper module for connect-assets to upload your files to a CDN (like Amazon S3)

### Installation

`npm install connect-assets-cdn`

### Usage (Cake Task)

To create a Cake task to upload new assets, follow this example.

**/s3.js**

    require("coffee-script");
    
    var uploader = require("./src/s3AssetUpload");
    
    uploader.upload(console.log, function(err, uploaded) {
        if(err) {
            return console.log("Error uploading: " + err.message);
            process.exit(1);
        }
    
        console.log("Completed");
        process.exit(0);
    });

**/src/s3AssetUpload.coffee**

    express = require 'express'
    assets = require "connect-assets"
    jsPaths = require "connect-assets-jspaths"
    
    {AssetsCDN} = require "connect-assets-cdn"
    
    # Either create a config file like here or set this to 
    # an object with amazon key, secret and bucket values
    # Also should have the assetsRoot; e.g. //s3.amazonaws.com/myBucket
    config = require "./config"
    
    primeCSS = (assets) ->
        # We only have one file to pre-compile for css
        # You might need to add more for your situation;
        # whatever you reference in your views should be 
        # referenced like this here
        assets.instance.options.helperContext.css "prod"
    
    upload = (log, done) ->
    
        # Set up a fake express server so we can load connect-assets
        app = express()
    
        opts = 
            # TODO: Set your assetsRoot
            servePath: config.assetsRoot
    
        app.use assets opts
    
        # Prime the CSS files
        primeCSS assets
        # Prime the JS files
        jsPaths assets
        
        # TODO: Set these from your config
        {key, secret, bucket} = config.amazon
    
        # Create our cdn manager and upload
        cdn = new AssetsCDN {assets, key, secret, bucket, log}
    
        cdn.upload done
    
    module.exports = {upload}

**/Cakefile** 

    task 's3', 'Upload builtAssets', ->
        # Set production NODE_ENV
        currentEnv = process.env
        currentEnv.NODE_ENV = "production"

        server = spawn 'node', ['s3.js'],
          env: currentEnv

        server.stdout.pipe process.stdout
        server.stderr.pipe process.stderr

### Usage (Before Starting Server)

    # You can also upload new assets before starting the server...

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

* Better uploader tests
* Check if files exist already on CDN before uploading

### Thanks

Made possible thanks to [connect-assets](https://github.com/TrevorBurnham/connect-assets), [knox](https://github.com/learnboost/knox).
    
### Copyright

Created by [Jacob Gable](http://jacobgable.com).  MIT License; no attribution required.