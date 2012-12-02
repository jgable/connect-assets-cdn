should = require "should"

AssetsCDN = require "../lib/AssetsCdn.coffee"

describe "AssetsCDN", ->
	mockAssets = 
		instance: 
			options:
				buildDir: "builtAssets"
			cachedRoutePaths: 
				'js/app.js': [ '/js/app-c67cb5fd84727c25fe3ed287207172c7.js' ],
				'js/controllers/admin_controller.js': [ '/js/controllers/admin_controller-188c17242f948dcc51fa4f3f352e2190.js' ],
				'js/lib/alertify.js': [ '/js/lib/alertify-d65f1d430256256fc2fcfcf9155db828.js' ],
				'js/live.js': [ '/js/live-71745e02922f52382e17fc4a4e636517.js' ],
				'js/main.js': [ '/js/main-ebd210bf74fa1823e40601ccd918b2c0.js' ],
				'js/models/base.js': [ '/js/models/base-ae553600d2d7dd2a4e40a901a35a6608.js' ],
				'js/routes.js': [ '/js/routes-216f3894e066b96bbd504a14c2025506.js' ],
				'js/views/layout.js': [ '/js/views/layout-a94e07ae61c7c37bded4108b7fb1e9a5.js' ] 

	fakeUploader = 
		listExistingFiles: (prefix, done) ->
			done null, []
		uploadFile: (localPath, remotePath, done) ->
			done null, remotePath

	cdn = null

	# Fill this in if you want to test the s3 upload capability
	# You'll also need to modify the cachedRoutePaths to real files
	config = 
		amazon: 
			key: ""
			secret: ""
			bucket: ""

	beforeEach ->
		cdn = new AssetsCDN { assets: mockAssets, uploader: fakeUploader }

	it "throws an error if no uploader or key is specified", ->
		toThrow = ->
			cdn = new AssetsCDN { assets: mockAssets }

		toThrow.should.throw "Must provide uploader, or key, secret and bucket in options"

	it "can load file names from connect-assets instance", ->
		files = cdn._getAssetFiles()

		should.exist files
		keyCount = 0
		for own key, val of mockAssets.instance.cachedRoutePaths
			keyCount++

		files.length.should.equal keyCount

	it "can load relative path correctly", ->
		files = cdn._getAssetFiles()

		should.exist files[0]
		expected = "#{mockAssets.instance.options.buildDir}/js/app-c67cb5fd84727c25fe3ed287207172c7.js"
		files[0].relative.should.equal expected

	it "calls upload files with relative paths", (done) ->
		files = cdn._getAssetFiles()

		fakeUploader.uploadFiles = (paths, progress, uploadDone) ->
			should.exist paths[0]

			paths[0].should.equal files[0].relative

			uploadDone null, paths

		cdn.upload (err, uploadedPaths) ->
			throw err if err

			done()

	###
	# This requires you to set up some test files and set the key/secret
	# I'd probably create a test/builtAssets directory with some files,
	# then change my mockAssets buildDir to 'test/builtAssets'
	# and make sure the cachedRoutePaths match your test builtAssets.
	it "can upload to s3", (done) ->
		cdn = new AssetsCDN 
			assets: mockAssets
			key: config.amazon.key
			secret: config.amazon.secret
			bucket: config.amazon.bucket

		files = cdn._getAssetFiles()

		cdn.upload (err, uploadedPaths) ->
			throw err if err

			should.exist uploadedPaths
			uploadedPaths.length.should.equal files.length
			uploadedPaths[0].should.equal files[0].relative

			done()
	###