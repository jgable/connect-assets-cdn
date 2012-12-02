
S3Uploader = require "./S3Uploader"

class AssetsCDN
	constructor: (opts) ->
		{assets, @uploader, @log} = opts

		throw new Error "Could not load assets module properties" if not assets?.instance?.cachedRoutePaths?

		unless @uploader
			unless opts.key? and opts.secret? and opts.bucket?
				throw new Error "Must provide uploader, or key, secret and bucket in options"

			{key, secret, bucket} = opts
			@uploader = new S3Uploader key, secret, bucket

		@assets = assets.instance

	upload: (done) ->
		files = @_getAssetFiles()

		relPaths = (file.relative for file in files)

		onProgress = (file) =>
			@log?("Asset Uploaded: #{file}")

		@uploader.uploadFiles relPaths, onProgress, done

	_getAssetFiles: ->
		# Getting builtAssets path from assets instance
		fullPre = "#{process.cwd()}/#{@assets.options.buildDir}"
		buildPre = "#{@assets.options.buildDir}"

		# This lines kinda long;
		# It returns the full path, relative path 
		# and part of the assets cached references
		({ full: "#{fullPre}#{builtFilePath}", relative: "#{buildPre}#{builtFilePath}", part: "#{builtFilePath}" } for own origFilePath, [builtFilePath] of @assets.cachedRoutePaths)

module.exports = AssetsCDN