fs = require "fs"
mime = require "mime"

knox = require "knox"
async = require "async"

class UploadError extends Error

	constructor: (msg, @response) ->
		super


class KnoxBase
	constructor: (@key, @secret, @bucket) ->

	_createClient: -> knox.createClient {@key, @secret, @bucket}


class KnoxFileLister extends KnoxBase

	listFiles: (prefix, done) ->
		client = @_createClient()

		client.list {prefix}, (err, data) ->
			return done err if err

			# TODO: Handle truncation?
			files = (content.Key for content in data.Contents when content.Key.slice(-1) isnt "/")

			done null, files


class KnoxFileUploader extends KnoxBase
	
	uploadPublicFile: (relPath, remPath, done) ->
		fullPath = "#{process.cwd()}/#{relPath}"
		fs.exists fullPath, (exists) =>
			throw new Error "File does not exist: #{relPath}" unless exists

			fs.readFile fullPath, (err, data) =>
				content = data.toString()

				contentType = mime.lookup fullPath

				# Add charset if it's known.
				charset = mime.charsets.lookup contentType
				if charset
					contentType += '; charset=' + charset

				farExpires = new Date(2022, 0, 1).toUTCString()
				
				# TODO: Expose these as options?
				oneDay = 60 * 60 * 24
				oneWeek = oneDay * 7
				oneMonth = oneWeek * 4
				oneYear = oneMonth * 12
				
				headers = 
					"Content-Length": content.length
					"Content-Type": contentType
					'x-amz-acl': 'public-read'
					"Cache-Control": "max-age=#{oneYear}"
					"Expires": farExpires

				client = @_createClient()
				req = client.put remPath, headers

				req.on "response", (res) ->
					return done null, remPath if 200 == res.statusCode

					err = new UploadError "Received non 200 response", res

					done err

				req.end content


class S3Uploader
	constructor: (@key, @secret, @bucket) ->

	uploadFile: (relPath, remPath, done) ->
		uploader = new KnoxFileUploader @key, @secret, @bucket

		uploader.uploadPublicFile relPath, remPath, done

	listExistingFiles: (prefix = "builtAssets", done) ->
		lister = new KnoxFileLister @key, @secret, @bucket

		lister.listFiles prefix, done

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