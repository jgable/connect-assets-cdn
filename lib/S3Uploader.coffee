s3 = require "s3-client"

async = require "async"

class S3Uploader
	constructor: (key, secret, bucket) ->
		@client = s3.createClient {key, secret, bucket}

	uploadFile: (relPath, remPath, done) ->
		uploader = @client.upload relPath, remPath

		uploader.on "error", done

		uploader.on "end", ->
			done null, remPath

	uploadFiles: (paths, progress, done) ->
		makeUpload = (relPath) =>
			(cb) =>
				@uploadFile relPath, relPath, (err, uploaded) ->
					return cb err if err

					progress?(uploaded)
					
					cb null, uploaded

		uploads = (makeUpload path for path in paths)

		async.series uploads, done

module.exports = S3Uploader